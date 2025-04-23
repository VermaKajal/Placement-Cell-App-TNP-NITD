import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_drive_page.dart';
import 'DriveUpdatepage.dart';

class GoingDrivesPage extends StatelessWidget {
  const GoingDrivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Going Drives'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ongoing_drives').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ongoing drives available.'));
          }

          final ongoingDrives = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ongoingDrives.length,
            itemBuilder: (context, index) {
              final drive = ongoingDrives[index].data() as Map<String, dynamic>;
              final companyName = drive['name'] ?? 'No Company Name';
              final description = drive['description'] ?? '';
              final postedDate = drive['posted'] ?? 'No Date';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business, color: Colors.teal, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Posted: $postedDate',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriveDetailsPage(
                                  driveId: ongoingDrives[index].id, // Pass the document ID
                                  driveData: drive,                // Pass the data
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OngoingDrivesPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Add New Drive',
      ),
    );
  }
}
