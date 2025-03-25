import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class MyNotesPage extends StatefulWidget {
  @override
  _MyNotesPageState createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  List<Map<String, String>> pdfFiles = [];

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pdfFiles.add({
          'name': result.files.single.name,
          'path': result.files.single.path ?? '', // Store the file path
        });
      });
    }
  }

  void _openPdf(String path) {
    OpenFile.open(path);
  }

  void _deletePdf(int index) {
    setState(() {
      pdfFiles.removeAt(index);  // Remove PDF from list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickPdf,
            child: Text('Upload PDF'),
          ),
          Expanded(
            child: pdfFiles.isEmpty
                ? const Center(child: Text('No PDFs uploaded yet.'))
                : ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text(pdfFiles[index]['name'] ?? ''),
                  onTap: () => _openPdf(pdfFiles[index]['path'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePdf(index),  // Delete button
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
