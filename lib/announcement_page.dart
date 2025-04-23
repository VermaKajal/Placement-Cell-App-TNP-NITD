import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
class Announce extends StatefulWidget {
  const Announce({super.key});

  @override
  _AnnounceState createState() => _AnnounceState();
}

class _AnnounceState extends State<Announce> with SingleTickerProviderStateMixin {
  final DatabaseReference _studentsRef = FirebaseDatabase.instance.ref('database').child('BTech');
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String selectedBranch = 'All'; // Default branch filter is 'All'

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    _studentsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> loadedStudents = [];

      if (data is List) {
        for (var student in data) {
          if (student != null) {
            loadedStudents.add({
              'name': student['Name'] ?? 'N/A',
              'batch': student['Batch'] ?? 'N/A',
              'offer': student['Offer'] ?? 'N/A',
              'ctc': student['CTC_in_lpa'] ?? 'N/A',
              'branch': student['Branch'] ?? 'N/A',
              'status': student['On_Off_campus'] ?? 'N/A',
            });
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          loadedStudents.add({
            'name': value['Name'] ?? 'N/A',
            'batch': value['Batch'] ?? 'N/A',
            'offer': value['Offer'] ?? 'N/A',
            'ctc': value['CTC_in_lpa'] ?? 'N/A',
            'branch': value['Branch'] ?? 'N/A',
            'status': value['On_Off_campus'] ?? 'N/A',
          });
        });
      }

      setState(() {
        students = loadedStudents;
        filteredStudents = loadedStudents; // Initially, no filters applied
      });
    });
  }

  // void _filterByBranch(String branch) {
  //   setState(() {
  //     if (branch == 'All') {
  //       filteredStudents = students;
  //     } else {
  //       filteredStudents = students.where((student) => student['branch'] == branch).toList();
  //     }
  //     selectedBranch = branch;
  //   });
  // }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TNP NITD', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set hamburger icon color to black
        ),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: _filterByBranch,
        //     icon: const Icon(Icons.filter_list),
        //     itemBuilder: (BuildContext context) {
        //       return [
        //         const PopupMenuItem(value: 'All', child: Text('All Branches')),
        //         const PopupMenuItem(value: 'CSE', child: Text('CSE')),
        //         const PopupMenuItem(value: 'ECE', child: Text('ECE')),
        //         const PopupMenuItem(value: 'EE', child: Text('EE')),
        //       ];
        //     },
        //   )
        // ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "STUDENTS"),
            Tab(text: "Top Offers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentTab(),
          _buildTopPlacementTab(),
        ],
      ),
    );
  }

  Widget _buildStudentTab() {
    return filteredStudents.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(filteredStudents[index]);
      },
    );
  }

  Widget _buildTopPlacementTab() {
    // Hardcoded list of students with their top offers
    final List<Map<String, dynamic>> topOffers = [
      {
        'name': 'Ekanshi Pal',
        'company': 'Atlassian',
        'ctc': 60,
        'branch': 'ECE',
        'batch': 2024,
        'image': 'assets/images/ekanshi.png', // Add image paths in your assets folder
        'linkedin': Uri.parse('https://www.linkedin.com/in/ekanshi-pal-909514191')
      },
      {
        'name': 'Atul Goyal',
        'company': 'DE SHAW',
        'ctc': 50,
        'branch': 'CSE',
        'batch': 2024,
        'image': 'assets/images/atul.png',
        'linkedin': Uri.parse('https://www.linkedin.com/in/atul-goyal-1ab40420a')
      },
      {
        'name': 'Palak Talwar',
        'company': 'Intuit',
        'ctc': 44,
        'branch': 'CSE',
        'batch': 2024,
        'image': 'assets/images/palak.png',
        'linkedin': Uri.parse('https://www.linkedin.com/in/palak-talwar-0739aa20a')
      },
      {
        'name': 'Aarya Jha',
        'company': 'Intuit',
        'ctc': 44,
        'branch': 'CSE',
        'batch': 2024,
        'image': 'assets/images/aarya.png',
        'linkedin': Uri.parse('https://www.linkedin.com/in/aarya-jha-4a8442203')
      },
      {
        'name': 'Swant Arya',
        'company': 'Arm Technologies',
        'ctc': 35,
        'branch': 'ECE',
        'batch': 2024,
        'image': 'assets/images/swant.png',
        'linkedin': Uri.parse('https://www.linkedin.com/in/swant-arya-73262017a')
      },
    ];

    return ListView.builder(
      itemCount: topOffers.length,
      itemBuilder: (context, index) {
        return _buildTopOfferCard(topOffers[index]);
      },
    );
  }

  Widget _buildTopOfferCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(student['image']), // Use image from assets
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student['company'],
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.login),
                  color: Colors.blueAccent,
                  onPressed: () {
                    _launchLinkedIn(student['linkedin']);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CTC : ${student['ctc']} LPA',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Branch : ${student['branch']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Batch : ${student['batch']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchLinkedIn(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  } }
  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    student['name'][0], // First character of the name as the logo
                    style: const TextStyle(fontSize: 24),
                  ),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        student['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student['branch'],
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Best Offer : ${student['offer']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'CTC : ${student['ctc']} LPA',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Batch : ${student['batch']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Status : ${student['status']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

