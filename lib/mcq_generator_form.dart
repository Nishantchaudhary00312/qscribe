import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class McqGeneratorFormPage extends StatefulWidget {
  const McqGeneratorFormPage({super.key});

  @override
  State<McqGeneratorFormPage> createState() => _McqGeneratorFormPageState();
}

class _McqGeneratorFormPageState extends State<McqGeneratorFormPage> {
  File? _pdfFile;
  String _difficulty = 'Easy';
  int _numQuestions = 1;

  // Form Fields
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  // ✅ Pick PDF
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

  // ✅ Submit Form and Send PDF to Flask
  Future<void> _submitForm() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF')),
      );
      return;
    }

    var uri = Uri.parse('http://192.168.171.218:5000/generate-mcqs');  // Replace with your Flask server IP
    var request = http.MultipartRequest('POST', uri);

    // Add PDF file
    request.files.add(await http.MultipartFile.fromPath('pdf', _pdfFile!.path));

    // Add form data
    request.fields['exam_name'] = _examNameController.text;
    request.fields['subject'] = _subjectNameController.text;
    request.fields['student_name'] = _studentNameController.text;
    request.fields['date'] = _dateController.text;
    request.fields['time'] = _timeController.text;
    request.fields['marks'] = _marksController.text;
    request.fields['difficulty'] = _difficulty;
    request.fields['numMCQs'] = _numQuestions.toString();

    // ✅ Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      List<dynamic> mcqs = jsonResponse['mcqs'];
      List<dynamic> answerKey = jsonResponse['answer_key'];

      // Navigate to MCQ Display Page
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => McqDisplayPage(jsonResponse: jsonResponse),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate MCQs. Status: ${response.statusCode}')),
      );
    }
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

            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (DD/MM/YYYY)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)', border: OutlineInputBorder()),
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
              items: ['Easy', 'Moderate', 'Difficult'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
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
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class McqDisplayPage extends StatelessWidget {
  final Map<String, dynamic> jsonResponse;

  const McqDisplayPage({super.key, required this.jsonResponse});

  @override
  Widget build(BuildContext context) {
    List<dynamic> mcqs = jsonResponse['mcqs'] ?? [];
    List<dynamic> answerKey = jsonResponse['answer_key'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Generated MCQs')),
      body: ListView.builder(
        itemCount: mcqs.length,
        itemBuilder: (context, index) {
          var mcq = mcqs[index];
          var answer = answerKey[index];

          // MCQ details
          String question = mcq['question'] ?? 'No Question';
          String difficulty = mcq['difficulty'] ?? 'Unknown';
          Map<String, dynamic> options = mcq['options'] ?? {};
          String correctAnswer = answer['correct'] ?? 'No Answer';

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Question
                  Text(
                    'Q${index + 1}: $question',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Display Options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: options.entries.map((entry) {
                      String optionKey = entry.key;
                      String optionValue = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '$optionKey: $optionValue',
                          style: TextStyle(
                            fontSize: 16,
                            color: optionValue == correctAnswer
                                ? Colors.green
                                : Colors.black,
                            fontWeight: optionValue == correctAnswer
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Correct Answer
                  Text(
                    '✅ Correct Answer: $correctAnswer',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Difficulty Level
                  Text(
                    '🔥 Difficulty: $difficulty',
                    style: TextStyle(
                      fontSize: 14,
                      color: difficulty == 'Easy'
                          ? Colors.blue
                          : difficulty == 'Medium'
                          ? Colors.orange
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

