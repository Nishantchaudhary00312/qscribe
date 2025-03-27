// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'dart:io';
//
// class NotesPage extends StatefulWidget {
//   const NotesPage({super.key});
//
//   @override
//   State<NotesPage> createState() => _NotesPageState();
// }
//
// class _NotesPageState extends State<NotesPage> {
//   List<File> _pdfFiles = [];
//
//   // Load PDF Files
//   Future<void> _loadPdfFiles() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final pdfDirectory = Directory(directory.path);
//
//     setState(() {
//       _pdfFiles = pdfDirectory
//           .listSync()
//           .whereType<File>()
//           .where((file) => file.path.endsWith('.pdf'))
//           .toList();
//     });
//   }
//
//   // Open PDF File
//   Future<void> _openPdf(File file) async {
//     final result = await OpenFile.open(file.path);
//     print("File opened: ${result.message}");
//   }
//
//   // Delete PDF File
//   Future<void> _deletePdf(File file) async {
//     if (await file.exists()) {
//       await file.delete();
//       _loadPdfFiles(); // Reload the list after deletion
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('${file.path.split('/').last} deleted')),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPdfFiles();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Saved PDFs')),
//       body: _pdfFiles.isEmpty
//           ? const Center(child: Text('No PDFs found.'))
//           : ListView.builder(
//         itemCount: _pdfFiles.length,
//         itemBuilder: (context, index) {
//           final pdfFile = _pdfFiles[index];
//
//           return ListTile(
//             title: Text(pdfFile.path.split('/').last),
//             onTap: () => _openPdf(pdfFile), // Open PDF on click
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deletePdf(pdfFile), // Delete PDF
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'dart:io';
//
// class NotesPage extends StatefulWidget {   // ✅ Corrected name
//   const NotesPage({super.key});
//
//   @override
//   State<NotesPage> createState() => _NotesPageState();
// }
//
// class _NotesPageState extends State<NotesPage> {
//   List<File> _pdfFiles = [];
//
//   // Load PDF Files
//   Future<void> _loadPdfFiles() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final pdfDirectory = Directory(directory.path);
//
//     setState(() {
//       _pdfFiles = pdfDirectory
//           .listSync()
//           .whereType<File>()
//           .where((file) => file.path.endsWith('.pdf'))
//           .toList();
//     });
//   }
//
//   // Open PDF File
//   Future<void> _openPdf(File file) async {
//     final result = await OpenFile.open(file.path);
//     print("File opened: ${result.message}");
//   }
//
//   // Delete PDF File
//   Future<void> _deletePdf(File file) async {
//     if (await file.exists()) {
//       await file.delete();
//       _loadPdfFiles(); // Reload the list after deletion
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('${file.path.split('/').last} deleted')),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPdfFiles();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Saved PDFs')),
//       body: _pdfFiles.isEmpty
//           ? const Center(child: Text('No PDFs found.'))
//           : ListView.builder(
//         itemCount: _pdfFiles.length,
//         itemBuilder: (context, index) {
//           final pdfFile = _pdfFiles[index];
//
//           return ListTile(
//             title: Text(pdfFile.path.split('/').last),
//             onTap: () => _openPdf(pdfFile), // Open PDF on click
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deletePdf(pdfFile), // Delete PDF
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:open_file/open_file.dart';
// // import 'dart:io';
// // import 'package:path_provider/path_provider.dart';
// //
// // class SavedPdfsPage extends StatefulWidget {
// //   const SavedPdfsPage({super.key});
// //
// //   @override
// //   State<SavedPdfsPage> createState() => _SavedPdfsPageState();
// // }
// //
// // class _SavedPdfsPageState extends State<SavedPdfsPage> {
// //   List<File> _pdfFiles = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSavedPdfs();
// //   }
// //
// //   // ✅ Load saved PDFs from the app's directory
// //   Future<void> _loadSavedPdfs() async {
// //     final directory = await getExternalStorageDirectory();
// //     final pdfDir = Directory(directory!.path);
// //
// //     if (pdfDir.existsSync()) {
// //       List<FileSystemEntity> files = pdfDir.listSync();
// //       List<File> pdfFiles = files
// //           .where((file) => file.path.endsWith('.pdf'))
// //           .map((file) => File(file.path))
// //           .toList();
// //
// //       setState(() {
// //         _pdfFiles = pdfFiles;
// //       });
// //     }
// //   }
// //
// //   // ✅ Open PDF using external viewer
// //   Future<void> _openPdf(File pdfFile) async {
// //     await OpenFile.open(pdfFile.path);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Saved PDFs')),
// //       body: _pdfFiles.isEmpty
// //           ? const Center(child: Text('No PDFs found.'))
// //           : ListView.builder(
// //         itemCount: _pdfFiles.length,
// //         itemBuilder: (context, index) {
// //           final pdfFile = _pdfFiles[index];
// //           final fileName = pdfFile.path.split('/').last;
// //
// //           return Card(
// //             margin: const EdgeInsets.all(10),
// //             child: ListTile(
// //               title: Text(fileName),
// //               trailing: IconButton(
// //                 icon: const Icon(Icons.download),
// //                 onPressed: () => _openPdf(pdfFile),  // ✅ Open the PDF
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<File> _pdfFiles = [];

  // Load PDF Files
  Future<void> _loadPdfFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory(directory.path);

    setState(() {
      _pdfFiles = pdfDirectory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
    });
  }

  // Open PDF File
  Future<void> _openPdf(File file) async {
    final result = await OpenFile.open(file.path);
    print("File opened: ${result.message}");
  }

  // Delete PDF File
  Future<void> _deletePdf(File file) async {
    if (await file.exists()) {
      await file.delete();
      _loadPdfFiles(); // Reload the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.path.split('/').last} deleted')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved PDFs')),
      body: _pdfFiles.isEmpty
          ? const Center(child: Text('No PDFs found.'))
          : ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfFile = _pdfFiles[index];

          return ListTile(
            title: Text(pdfFile.path.split('/').last),
            onTap: () => _openPdf(pdfFile), // Open PDF on click
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePdf(pdfFile), // Delete PDF
            ),
          );
        },
      ),
    );
  }
}