import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
//
// class AddDrivePage extends StatefulWidget {
//   @override
//   _AddDrivePageState createState() => _AddDrivePageState();
// }
//
// class _AddDrivePageState extends State<AddDrivePage> {
//   final _formKey = GlobalKey<FormState>();
//   String companyName = '';
//   String description = '';
//   // Add other variables as needed
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add New Drive')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Company Name'),
//                 onSaved: (value) => companyName = value ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Description'),
//                 onSaved: (value) => description = value ?? '',
//               ),
//               // Add more fields as needed
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     // Code to save data (e.g., to Firebase or a database)
//                     Navigator.pop(context); // Go back to the Going Drives page
//                   }
//                 },
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
class OngoingDrivesPage extends StatefulWidget {
  const OngoingDrivesPage({super.key});

  @override
  State<OngoingDrivesPage> createState() => _OngoingDrivesPageState();
}

class _OngoingDrivesPageState extends State<OngoingDrivesPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  List<Map<String, dynamic>> announcements = [];
  PlatformFile? _pdfFile;

  void _submitDetails() {
    if (_companyNameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final announcement = {
        'name': _companyNameController.text,
        'description': _descriptionController.text,
        'link': _linkController.text.isEmpty ? null : _linkController.text,
        'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
      };

      FirebaseFirestore.instance
          .collection('ongoing_drives') // Firestore collection name
          .add(announcement)
          .then((_) {
        setState(() {
          announcements.add(announcement);
          _companyNameController.clear();
          _descriptionController.clear();
          _linkController.clear();
          _pdfFile = null; // Reset the selected PDF
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details submitted successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit details: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
    }
  }

  Future<void> _pickPDF() async {
    // Open the file picker to select a PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = result.files.first;
      });
    }
  }





  Future<void> _uploadPDF() async {
    if (_pdfFile != null && _pdfFile!.path != null) {
      try {
        // Read the file using the provided path
        final file = File(_pdfFile!.path!);

        // Create a reference in Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final fileRef = storageRef.child('ongoing_drives_pdfs/${_pdfFile!.name}');

        // Upload the file to Firebase Storage
        final uploadTask = fileRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});

        // Get the file's download URL
        final downloadURL = await snapshot.ref.getDownloadURL();

        // Save the download URL in Firestore along with other details
        FirebaseFirestore.instance.collection('ongoing_drives').add({
          'pdfLink': downloadURL, // Store the PDF link
          'name': _companyNameController.text,
          'description': _descriptionController.text,
          'link': _linkController.text.isEmpty ? null : _linkController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _companyNameController.clear();
          _descriptionController.clear();
          _linkController.clear();
          _pdfFile = null; // Reset selected file
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded and link saved!')),
        );
      } catch (e) {
        print('Error uploading PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload PDF: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF selected for upload')),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Drives', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Company Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              TextFormField(controller: _companyNameController, decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 4),
              const SizedBox(height: 12),
              TextFormField(controller: _linkController, decoration: const InputDecoration(labelText: 'Add Link (Optional)', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickPDF,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadPDF,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 30),
              const Text('Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const Divider(),
              if (announcements.isEmpty)
                const Text('No announcements yet.', style: TextStyle(fontSize: 16))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(announcement['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(announcement['description'] ?? ''),
                            if (announcement['link'] != null && announcement['link']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Open the link
                                  },
                                  child: Text(announcement['link'], style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                ),
                              ),
                            if (announcement['pdfLink'] != null)
                              GestureDetector(
                                onTap: () {
                                  // Open the PDF
                                },
                                child: Text('Open PDF', style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}