import 'package:flutter/material.dart';
import 'question_paper_form.dart';
import 'my_notes_page.dart';
import 'mcq_generator_form.dart';
import 'login_page.dart';
import 'notes.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  HomePage({required this.userName, required this.userEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showProfile = false;  // Toggle for showing profile section

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QScribe', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: _buildCustomDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Question Paper Generator with White Box
              _buildCardWithDescription(
                context,
                title: "Question Paper Generator",
                description: "Create customized question papers with AI assistance",
                color1: Colors.blueAccent,
                color2: Colors.purpleAccent,
                icon: Icons.article,
                buttonText: "Generate Questions",
                whiteBoxText: "Generate comprehensive question papers based on subject, difficulty level, and topics.",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionPaperFormPage()),
                ),
              ),
              SizedBox(height: 16),

              // Add Notes with White Box
              _buildCardWithDescription(
                context,
                title: "Add Notes",
                description: "Create and organize your study notes",
                color1: Colors.greenAccent,
                color2: Colors.teal,
                icon: Icons.edit,
                buttonText: "Add Notes",
                whiteBoxText: "Add, edit, and organize your study notes with rich text formatting and categorization.",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyNotesPage()),
                ),
              ),
              SizedBox(height: 16),

              // MCQ Generator with White Box
              _buildCardWithDescription(
                context,
                title: "MCQ Generator",
                description: "Create multiple-choice questions with AI",
                color1: Colors.orangeAccent,
                color2: Colors.deepOrange,
                icon: Icons.quiz,
                buttonText: "Generate MCQs",
                whiteBoxText: "Generate multiple-choice questions with options and answers based on your content.",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => McqGeneratorFormPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Drawer with Profile Section
  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Profile Section
          GestureDetector(
            onTap: () {
              setState(() {
                showProfile = !showProfile;  // Toggle profile section
              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: 70, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    widget.userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Profile Section (Expands on Tap)
          if (showProfile)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Name: ${widget.userName}", style: TextStyle(fontSize: 16)),
                  Text("Email: ${widget.userEmail}", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

          ListTile(
            leading: Icon(Icons.home, color: Colors.blue),
            title: Text('Home'),
            tileColor: Colors.blue.withOpacity(0.1),
            onTap: () => Navigator.pop(context),
          ),
          // ListTile(
          //   leading: Icon(Icons.article, color: Colors.black54),
          //   title: Text('Question Generator'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => QuestionPaperFormPage()),
          //   ),
          // ),
          ListTile(
            leading: Icon(Icons.note, color: Colors.black54),
            title: Text('Notes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotesPage()),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.quiz, color: Colors.black54),
          //   title: Text('MCQ Generator'),
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => McqGeneratorFormPage()),
          //   ),
          // ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black54),
            title: Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
              ),
              icon: Icon(Icons.login, color: Colors.purple),
              label: Text('Login', style: TextStyle(color: Colors.purple)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.purple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card with White Box Widget
  Widget _buildCardWithDescription(
      BuildContext context, {
        required String title,
        required String description,
        required Color color1,
        required Color color2,
        required IconData icon,
        required String buttonText,
        required String whiteBoxText,
        required VoidCallback onPressed,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              whiteBoxText,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color2,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
