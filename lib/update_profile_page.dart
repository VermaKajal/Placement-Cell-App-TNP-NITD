import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _phoneNumber;
  String? _rollNumber;
  String? _batch;
  String? _branch;
  String? _course;
  String? _cgpa;
  XFile? _profileImage;
  String? _resumeFile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to pick an image for the profile
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    _profileImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  // Method to pick a resume file
  Future<void> _pickResumeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF files
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = result.files.single.path; // Store the file path
      });
    }
  }

  // Method to upload file (profile image or resume) to Firebase Storage
  Future<String?> _uploadFile(String? filePath, String folder) async {
    if (filePath == null) return null;

    try {
      // Extract the file name from the file path
      String fileName = path.basename(filePath);

      // Get a reference to Firebase Storage with the original file name
      final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');

      // Upload the file
      final uploadTask = await ref.putFile(File(filePath));

      // Return the download URL as a string (not Uri)
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl; // Return it as a string directly
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
      return null;
    }
  }


  // Save profile details to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Upload profile image and resume, if selected
      String? profileImageUrl = await _uploadFile(_profileImage?.path, 'profile_images');
      String? resumeUrl = await _uploadFile(_resumeFile, 'resumes');

      // Save the data in Firestore under 'profile' collection
      try {
        await _firestore.collection('profile').doc(userId).set({
          'username': _username,
          'phoneNumber': _phoneNumber,
          'rollNumber': _rollNumber,
          'batch': _batch,
          'branch': _branch,
          'course': _course,
          'cgpa': _cgpa,
          'profileImageUrl': profileImageUrl,
          'resumeUrl': resumeUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated!')),
        );

        // Return the updated profile back to the previous page
        Map<String, dynamic> updatedProfile = {
          'username': _username,
          'phoneNumber': _phoneNumber,
          'rollNumber': _rollNumber,
          'batch': _batch,
          'branch': _branch,
          'course': _course,
          'cgpa': _cgpa,
          'profileImageUrl': profileImageUrl,
          'resumeUrl': resumeUrl,
        };
        Navigator.pop(context, updatedProfile);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Personal Information
              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                  child: const Icon(Icons.camera_alt, size: 30),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) => _username = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) => _phoneNumber = value,
              ),

              const SizedBox(height: 20),

              // Academic Details
              const Text(
                'Academic Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Roll Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your roll number';
                  }
                  return null;
                },
                onSaved: (value) => _rollNumber = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Batch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your batch';
                  }
                  return null;
                },
                onSaved: (value) => _batch = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Branch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your branch';
                  }
                  return null;
                },
                onSaved: (value) => _branch = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Course'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your course';
                  }
                  return null;
                },
                onSaved: (value) => _course = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CGPA'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your CGPA';
                  }
                  return null;
                },
                onSaved: (value) => _cgpa = value,
              ),

              const SizedBox(height: 20),

              // Available Resume
              const Text(
                'Available Resume',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickResumeFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('Upload Resume')),
                ),
              ),
              const SizedBox(height: 10),
              if (_resumeFile != null)
                Text('Selected: ${path.basename(_resumeFile!)}'), // Display the file name

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
