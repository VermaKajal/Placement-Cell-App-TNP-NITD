import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriveDetailsPage extends StatefulWidget {
  final String driveId; // ID of the Firestore document
  final Map<String, dynamic> driveData; // Data of the selected drive

  const DriveDetailsPage({super.key, required this.driveId, required this.driveData});

  @override
  _DriveDetailsPageState createState() => _DriveDetailsPageState();
}

class _DriveDetailsPageState extends State<DriveDetailsPage> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the existing description
    _descriptionController = TextEditingController(text: widget.driveData['description'] ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateDrive() async {
    try {
      await FirebaseFirestore.instance
          .collection('ongoing_drives')
          .doc(widget.driveId)
          .update({'description': _descriptionController.text});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update drive: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drive Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.driveData['name'] ?? 'No Company Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Posted: ${widget.driveData['posted'] ?? 'No Date'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _updateDrive,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
