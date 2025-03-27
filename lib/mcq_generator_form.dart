import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'notes.dart';
class McqGeneratorFormPage extends StatefulWidget {
  const McqGeneratorFormPage({super.key});

  @override
  State<McqGeneratorFormPage> createState() => _McqGeneratorFormPageState();
}

class _McqGeneratorFormPageState extends State<McqGeneratorFormPage> {
  File? _pdfFile;
  String _difficulty = 'Easy';
  int _numQuestions = 1;
  List<dynamic> _mcqs = [];  // To store generated MCQs

  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // ✅ Function to Pick Time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF')),
      );
      return;
    }

    var uri = Uri.parse('http://192.168.171.216:5000/generate-mcqs');  // Replace with your Flask server IP
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('pdf', _pdfFile!.path));
    request.fields['exam_name'] = _examNameController.text;
    request.fields['subject'] = _subjectNameController.text;
    request.fields['student_name'] = _studentNameController.text;
    request.fields['date'] = _dateController.text;
    request.fields['time'] = _timeController.text;
    request.fields['marks'] = _marksController.text;
    request.fields['difficulty'] = _difficulty;
    request.fields['numMCQs'] = _numQuestions.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      setState(() {
        _mcqs = jsonResponse['mcqs'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate MCQs. Status: ${response.statusCode}')),
      );
    }
  }

  // ✅ New Function to Download Notes PDF
  Future<void> _downloadNotesPdf() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notes uploaded to generate PDF')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          // ✅ Add Form Details at the Top
          content.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Exam Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Exam Name: ${_examNameController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Subject: ${_subjectNameController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Student Name: ${_studentNameController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Date: ${_dateController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Time: ${_timeController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Marks: ${_marksController.text}', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Difficulty: $_difficulty', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
              ],
            ),
          );

          // ✅ Add MCQs Section
          content.add(
            pw.Text('Generated MCQs:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          );
          content.add(pw.SizedBox(height: 10));

          for (int i = 0; i < _mcqs.length; i++) {
            var mcq = _mcqs[i];
            String question = mcq['question'] ?? 'No Question';
            Map<String, dynamic> options = mcq['options'] ?? {};
            String correctAnswer = mcq['correct'] ?? 'No Answer';

            content.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Q${i + 1}: $question', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  ...options.entries.map((option) => pw.Text(
                    '${option.key}. ${option.value}',
                    style: pw.TextStyle(fontSize: 12),
                  )),
                  pw.SizedBox(height: 5),
                  //pw.Text('✅ Correct Answer: $correctAnswer', style: pw.TextStyle(fontSize: 12, color: PdfColors.green)),
                  pw.SizedBox(height: 15),
                ],
              ),
            );
          }

          return content;
        },
      ),
    );
    final output = await getApplicationDocumentsDirectory();
    final filePath = '${output.path}/MCQ_paper_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('MCQ saved at $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ Generator Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Fields
            TextFormField(
              controller: _examNameController,
              decoration: const InputDecoration(labelText: 'Exam Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _subjectNameController,
              decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _studentNameController,
              decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // ✅ Date Picker Field with Icon
            InkWell(
              onTap: _pickDate,
              child: IgnorePointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),  // 📅 Calendar icon
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

// ✅ Time Picker Field with Icon
            InkWell(
              onTap: _pickTime,
              child: IgnorePointer(
                child: TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),  // ⏰ Clock icon
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _pickPdf,
              child: const Text('Upload PDF'),
            ),
            if (_pdfFile != null) Text('Selected PDF: ${_pdfFile!.path}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _difficulty,
              items: ['Easy', 'Moderate', 'Difficult']
                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (value) => setState(() => _difficulty = value!),
              decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of MCQs', border: OutlineInputBorder()),
              onChanged: (value) => _numQuestions = int.tryParse(value) ?? 1,
            ),
            const SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(width: 16),  // Space between buttons
                  ElevatedButton(
                    onPressed: _downloadNotesPdf,  // ✅ Updated button function
                    child: const Text('Download PDF'),
                  ),
                ],
              ),
            ),

            if (_mcqs.isNotEmpty) const SizedBox(height: 20),
            if (_mcqs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generated MCQs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mcqs.length,
                    itemBuilder: (context, index) {
                      var mcq = _mcqs[index];
                      String question = mcq['question'] ?? 'No Question';
                      Map<String, dynamic> options = mcq['options'] ?? {};
                      String correctAnswer = mcq['correct'] ?? 'No Answer';

                      return ListTile(
                        title: Text('Q${index + 1}: $question'),
                        //subtitle: Text('✅ Correct Answer: $correctAnswer'),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
