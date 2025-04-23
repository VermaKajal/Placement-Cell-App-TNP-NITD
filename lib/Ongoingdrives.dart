import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StudentDriveDetail.dart';

class StudentOngoingDrivesPage extends StatelessWidget {
  const StudentOngoingDrivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Drives'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ongoing_drives')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data.'));
          }

          final drives = snapshot.data?.docs ?? [];

          if (drives.isEmpty) {
            return const Center(
              child: Text('No ongoing drives at the moment.'),
            );
          }

          return ListView.builder(
            itemCount: drives.length,
            itemBuilder: (context, index) {
              final drive = drives[index];
              final documentId = drive.id;
              final name = drive['name'] ?? 'Unknown Company';
              final description = drive['description'] ?? 'No description provided.';
              final timestamp = drive['timestamp'] != null
                  ? (drive['timestamp'] as Timestamp).toDate().toString()
                  : 'No timestamp';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriveDetailsPage(
                        documentId: documentId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Posted: $timestamp',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriveDetailsPage(
                                      documentId: documentId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'View Details',
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
