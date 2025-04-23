import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _username = "User"; // Default username
  String _phoneNumber = ""; // Placeholder for phone number
  String _rollNumber = ""; // Placeholder for roll number
  String _batch = ""; // Placeholder for batch
  String _branch = ""; // Placeholder for branch
  String _course = ""; // Placeholder for course
  String _cgpa = ""; // Placeholder for CGPA
  Uri? _profileImageUrl; // Change from String to Uri?
  Uri? _resumeUrl; // Placeholder for resume URL
  bool _isLoading = true; // Loading state to show loading indicator

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile data when the widget initializes
  }

  Future<void> _fetchUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
    if (userId != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('profile').doc(userId).get();
        if (doc.exists) {
          setState(() {
            _username = doc['username'] ?? _username;
            _phoneNumber = doc['phoneNumber'] ?? _phoneNumber;
            _rollNumber = doc['rollNumber'] ?? _rollNumber;
            _batch = doc['batch'] ?? _batch;
            _branch = doc['branch'] ?? _branch;
            _course = doc['course'] ?? _course;
            _cgpa = doc['cgpa'] ?? _cgpa;

            // Check for profile image URL in Firebase Storage
            String? profileImagePath = doc['profileImageUrl'];
            if (profileImagePath != null && profileImagePath.isNotEmpty) {
              _getProfileImageFromStorage(profileImagePath);
            } else {
              _profileImageUrl = null; // No profile image uploaded
            }

            // Check for resume URL
            _resumeUrl = doc['resumeUrl'] != null ? Uri.tryParse(doc['resumeUrl']) : null;

            _isLoading = false; // Stop loading
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }

  Future<void> _getProfileImageFromStorage(String imagePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);
      String imageUrl = await storageRef.getDownloadURL();
      setState(() {
        _profileImageUrl = Uri.parse(imageUrl);
      });
    } catch (e) {
      setState(() {
        _profileImageUrl = null; // If image fetch fails, set null (fallback to Google account profile)
      });
    }
  }


  // Method to launch the resume URL (download the file)
  // Future<void> _downloadResume() async {
  //   if (_resumeUrl != null) {
  //     try {
  //       if (await canLaunchUrl(_resumeUrl!)) {
  //         await launchUrl(_resumeUrl!); // This will open the resume URL in the browser
  //       } else {
  //         throw 'Could not launch $_resumeUrl';
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening resume: $e')));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildProfileOptions(context),
          const SizedBox(height: 20),
          // if (_resumeUrl != null)
          //   ElevatedButton(
          //     onPressed: _downloadResume,
          //     child: const Text('Download Resume'),
          //   ),
          const SizedBox(height: 20),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  // Profile header with user info
  Widget _buildProfileHeader() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!.toString()) // Display image from Firebase Storage
                  : NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? 'https://www.istockphoto.com/photos/default-image'), // Fallback to Google account profile picture
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $_username', // Display username
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_rollNumber), // Display roll number
                Text('Branch: $_branch | Batch: $_batch'), // Display branch and batch
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Profile options like Personal Information, Academic Details, etc.
  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Personal Information'),
          onTap: () {
            Navigator.pushNamed(context, '/personal_information');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('Academic Details'),
          onTap: () {
            Navigator.pushNamed(context, '/academic_details');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Available Resume'),
          onTap: () {
            Navigator.pushNamed(context, '/available_resume');
          },
        ),
      ],
    );
  }

  // Quick actions like Update Profile, Reset Password, etc.
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Update Profile'),
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              '/update_profile',
              arguments: {
                'username': _username,
                'phoneNumber': _phoneNumber,
                'rollNumber': _rollNumber,
                'batch': _batch,
                'branch': _branch,
                'course': _course,
                'cgpa': _cgpa,
                'profileImageUrl': _profileImageUrl?.toString(), // Pass the profile image URL as String if needed
                'resumeUrl': _resumeUrl?.toString(), // Pass the resume URL as String if needed
              },
            );

            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                _username = result['username'];
                _phoneNumber = result['phoneNumber'];
                _rollNumber = result['rollNumber'];
                _batch = result['batch'];
                _branch = result['branch'];
                _course = result['course'];
                _cgpa = result['cgpa'];

                _profileImageUrl = result['profileImageUrl'] != null ? Uri.tryParse(result['profileImageUrl']) : null; // Update profile image URL
                _resumeUrl = result['resumeUrl'] != null ? Uri.tryParse(result['resumeUrl']) : null; // Update resume URL
              });
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Saved Opportunities'),
          onTap: () {
            Navigator.pushNamed(context, '/saved_opportunities');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: const Text('Reset Password'),
          onTap: () {
            Navigator.pushNamed(context, '/reset_password');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Report Issue'),
          onTap: () {
            Navigator.pushNamed(context, '/report_issue');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('FAQs'),
          onTap: () {
            Navigator.pushNamed(context, '/faqs');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ],
    );
  }
}

