import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminpage.dart'; // Import the Admin Page
import 'home_page.dart'; // Import the Student Dashboard Page

class RolePage extends StatelessWidget {
   RolePage({super.key});

  // Hardcoded list of admin email IDs
  final List<String> adminEmails = [
    "211210014@nitdelhi.ac.in",
    "admin2@example.com",
  ];

  // Function to check if the user is an admin
  Future<bool> isAdmin(String email) async {
    // Example: Check against a Firestore collection (Optional)
    // Uncomment this if you want to store admin emails in Firestore
    /*
    final snapshot = await FirebaseFirestore.instance
        .collection('admins')
        .doc(email)
        .get();
    return snapshot.exists;
    */

    // Check against the hardcoded list
    return adminEmails.contains(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'TNP NITD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome! Proceed as Student or Admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Student Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: const Icon(Icons.school, size: 24),
              label: const Text('Student', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Admin Button
            ElevatedButton.icon(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  // Show error if no user is logged in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in first.')),
                  );
                  return;
                }

                final email = user.email;

                if (email != null && await isAdmin(email)) {
                  // Navigate to Admin Page if email is valid
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                } else {
                  // Show error if not authorized
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are not authorized as an admin.')),
                  );
                }
              },
              icon: const Icon(Icons.admin_panel_settings, size: 24),
              label: const Text('Admin', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
