import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableResumePage extends StatefulWidget {
  const AvailableResumePage({super.key});

  @override
  _AvailableResumePageState createState() => _AvailableResumePageState();
}

class _AvailableResumePageState extends State<AvailableResumePage> {
  String? _resumeUrl;
  bool _isLoading = true;
  bool _isPdfLoading = false;  // Track PDF loading state
  String? _pdfPath;  // Store local path for the downloaded PDF

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchResumeUrl();
  }

  // Fetch the resume URL from Firestore
  Future<void> _fetchResumeUrl() async {
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch the document from Firestore for the current user
      var userProfile = await FirebaseFirestore.instance.collection('profile').doc(userId).get();

      if (userProfile.exists && userProfile.data() != null) {
        // Fetch the resume URL from Firestore
        String? resumeUrl = userProfile['resumeUrl'];

        // Log the fetched resume URL to console
        print("Fetched resume URL: $resumeUrl");

        setState(() {
          _resumeUrl = resumeUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching resume: $e')));
    }
  }

  Future<void> _downloadAndShowResume() async {
    if (_resumeUrl == null) return;

    print("Downloading resume from URL: $_resumeUrl");

    setState(() {
      _isPdfLoading = true;
    });

    try {
      // Create a reference to the resume in Firebase Storage
      Reference storageReference = _storage.refFromURL(_resumeUrl!);

      // Log the reference URL
      print("Storage reference URL: ${storageReference.fullPath}");

      // Get the temporary file path for the PDF
      Directory tempDir = await getTemporaryDirectory();
      String localPath = '${tempDir.path}/your_resume.pdf';  // Temporary path

      // Download the file
      await storageReference.writeToFile(File(localPath));

      // Check if the file exists
      bool fileExists = await File(localPath).exists();
      print("File exists at $localPath: $fileExists");

      if (fileExists) {
        setState(() {
          _pdfPath = localPath;
          _isPdfLoading = false;
        });

        // Show the PDF after download
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewPage(pdfPath: _pdfPath!),
          ),
        );
      } else {
        print("File not found after download.");
        setState(() {
          _isPdfLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: PDF file not found after download.')));
      }
    } catch (e) {
      setState(() {
        _isPdfLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading resume: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Resume'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_resumeUrl != null) // Show resume URL if available
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Resume:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _downloadAndShowResume,  // Handle resume download and view
                    child: Text(
                      'View Resume',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            else
              const Text('No resume uploaded'), // Display message when resume is not uploaded
          ],
        ),
      ),
    );
  }
}

// PDF View Page (after download)
class PdfViewPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewPage({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resume PDF')),
      body: SfPdfViewer.file(
        File(pdfPath),  // Load PDF from local file path
      ),
    );
  }
}
