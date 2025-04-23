// AdminPage.dart
import 'package:flutter/material.dart';
import 'GoingDrivepage.dart';
import 'reportgeneration.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminPanelCard(
                title: 'Upcoming Companies',
                onTap: () {
                  // Navigate to Upcoming Companies section
                },
              ),
              const SizedBox(height: 15),
              AdminPanelCard(
                title: 'Updates on Ongoing Drives',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoingDrivesPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              AdminPanelCard(
                title: 'Report Generation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportGenerationPage(),
                    ),
                  );
                  // Navigate to Report Generation section
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPanelCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const AdminPanelCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
