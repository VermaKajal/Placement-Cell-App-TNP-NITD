import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';  // Import dart:io for File handling

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Personal Information')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('profile')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User profile not found.'));
          }

          final doc = snapshot.data!;
          final _username = doc['username'] ?? '';
          final _phoneNumber = doc['phoneNumber'] ?? '';
          final _rollNumber = doc['rollNumber'] ?? '';
          final _batch = doc['batch'] ?? '';
          final _branch = doc['branch'] ?? '';
          final _course = doc['course'] ?? '';
          final _cgpa = doc['cgpa'] ?? '';
          final _profileImageUrl = doc['profileImageUrl'] ?? '';
          final _resumeUrl = doc['resumeUrl'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: _profileImageUrl.isNotEmpty
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_profileImageUrl),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: const Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Information
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Username', _username),
                          _buildInfoRow('Phone Number', _phoneNumber),
                          _buildInfoRow('Roll Number', _rollNumber),
                          _buildInfoRow('Batch', _batch),
                          _buildInfoRow('Branch', _branch),
                          _buildInfoRow('Course', _course),
                          _buildInfoRow('CGPA', _cgpa),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resume Button (Download)
                  _resumeUrl != null && _resumeUrl.isNotEmpty
                      ? Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _downloadResume(_resumeUrl!, context); // Pass context here
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text('Download Resume'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  )
                      : const Center(child: Text('Resume not found.')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to build information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not Available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Method to download the resume from Firebase Storage
  Future<void> _downloadResume(String resumeUrl, BuildContext context) async {
    try {
      // Get the directory where the file will be saved
      final appDocDir = await getApplicationDocumentsDirectory();
      final savePath = '${appDocDir.path}/resume.pdf';  // Saving as .pdf

      // Proceed with the rest of your code
      final storageRef = FirebaseStorage.instance.refFromURL(resumeUrl);
      await storageRef.writeToFile(File(savePath));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resume downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download resume: $e')),
      );
    }
  }
}
