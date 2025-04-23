import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'announcement_page.dart';
import 'auth_service.dart';
import 'profile_page.dart'; // Import Profile Page
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get current logged-in user

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Panel',
          style: TextStyle(color: Colors.white), // White text
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set hamburger icon color to black
        ),
// Black background for AppBar
      ),
      drawer: Drawer( // Side navigation drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user != null && user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, ${user?.displayName ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 32),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/'); // Navigate to home (root page)
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Your Profile'),
              onTap: () {
                Navigator.pushNamed(
                    context,'/profilepage'
                  // Navigate to ProfilePage
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildCard(
            context,
            'assets/images/announcement.png',
            'Jobs and Opportunities',
            '/announcements', // Pass route name as a string
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            'assets/images/jobs.png', // Replace with actual image path
            'Announcements',
            '/search_jobs', // Navigate to Search Jobs page
          ),
          const SizedBox(height: 20),
          // Add the new card here
          _buildCard(
            context,
            'assets/images/drives.jpeg', // Replace with the actual image path for Ongoing Drives
            'Ongoing Drives',
            '/ongoing_drives', // Navigate to Ongoing Drives page
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            'assets/images/vacancies.png', // Replace with actual image path
            'Placement Statistics',
            '/placement_statistics', // Navigate to Vacancies page
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            'assets/images/resume.png', // Replace with actual image path
            'Resume Checker',
            '/resume_checker', // Navigate to Resume Checker page
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            'assets/images/study_material.png', // Replace with actual image path
            'Study Material',
            '/study_material', // Navigate to Study Material page
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final authService = FirebaseAuthService();
                final googleService = GoogleSignIn();
                await googleService.signOut(); // Sign out user from Firebase and Google
                Navigator.pushReplacementNamed(context, '/'); // Navigate back to login
              },
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent, // Background color for logout button
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.white),
            label: '',
          ),
        ],
          onTap: (index) {
            // Handle navigation based on the index of the tapped item
            switch (index) {
              case 0: // Home
                Navigator.pushReplacementNamed(
                    context, '/home_page'); // Navigate to home (root page)
                break;
              case 1: // Notifications
                Navigator.pushNamed(context,
                    '/notifications'); // Navigate to Notifications page (change as needed)
                break;
              case 2: // Profile
                Navigator.pushNamed(
                    context, '/profilepage'); // Navigate to ProfilePage
                break;
            }
          },
      ),
    );
  }

  Widget _buildCard(BuildContext context, String imagePath, String title, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName); // Navigate to respective page
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imagePath,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}