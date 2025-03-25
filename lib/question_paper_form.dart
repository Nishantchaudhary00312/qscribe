import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class QuestionPaperFormPage extends StatefulWidget {
  const QuestionPaperFormPage({super.key});

  @override
  State<QuestionPaperFormPage> createState() => _QuestionPaperFormPageState();
}

class _QuestionPaperFormPageState extends State<QuestionPaperFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _pdfPath;
  String _difficulty = 'Easy';
  int _numQuestions = 1;
  List<Map<String, dynamic>> _questions = [];

  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  // ✅ PDF Picker Function
  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pdfPath = result.files.single.path;
        });
      }
    } catch (e) {
      print('Error picking PDF: $e');
    }
  }

  // ✅ Send Data to Flask Server
  Future<void> _sendDataToServer() async {
    if (_pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF file.')),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.171.218:5000/generate-questions');  // Flask server URL
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('pdf', _pdfPath!),
    );

    request.fields['user'] = 'testUser';
    request.fields['pass'] = 'testPass';
    request.fields['difficulty'] = _difficulty.toLowerCase();
    request.fields['numQuestions'] = _numQuestions.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      setState(() {
        _questions = List<Map<String, dynamic>>.from(jsonResponse['questions']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questions generated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate questions.')),
      );
    }
  }

  // ✅ Generate and Save PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Question Paper',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Exam Name: ${_examNameController.text}'),
            pw.Text('Subject: ${_subjectNameController.text}'),
            pw.Text('Student: ${_studentNameController.text}'),
            pw.Text('Date: ${_dateController.text}'),
            pw.Text('Time: ${_timeController.text}'),
            pw.Text('Marks: ${_marksController.text}'),
            pw.Text('Difficulty: $_difficulty'),
            pw.Text('Number of Questions: $_numQuestions'),
            pw.SizedBox(height: 20),

            // Questions
            pw.Text('Questions:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ..._questions.map((q) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Difficulty: ${q['difficulty']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Question: ${q['question']}'),
                pw.SizedBox(height: 10),
              ],
            )),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final filePath = '${output.path}/question_paper_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Fields
              _buildTextField(_examNameController, 'Exam Name'),
              _buildTextField(_subjectNameController, 'Subject Name'),
              _buildTextField(_studentNameController, 'Student Name'),
              _buildTextField(_dateController, 'Date (YYYY-MM-DD)'),
              _buildTextField(_timeController, 'Time (HH:MM)'),
              _buildTextField(_marksController, 'Marks', isNumber: true),

              // PDF Upload
              ElevatedButton(
                onPressed: _pickPdf,
                child: const Text('Upload PDF'),
              ),
              if (_pdfPath != null)
                Text('Selected PDF: $_pdfPath', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),

              // Difficulty & Num Questions
              const Text('Difficulty Level:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _difficulty,
                items: ['Easy', 'Medium', 'Hard']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) => setState(() => _difficulty = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                TextEditingController(text: '$_numQuestions'),
                'Number of Questions',
                isNumber: true,
                onChanged: (value) => _numQuestions = int.tryParse(value) ?? 1,
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _sendDataToServer,
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: _generatePdf,
                    child: const Text('Download PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Display Questions
              if (_questions.isNotEmpty) ...[
                const Text('Generated Questions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text('Difficulty: ${_questions[index]['difficulty']}'),
                    subtitle: Text('Question: ${_questions[index]['question']}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
