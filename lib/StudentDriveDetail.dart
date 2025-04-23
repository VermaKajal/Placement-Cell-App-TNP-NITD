import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DrivesListPage extends StatefulWidget {
  const DrivesListPage({super.key});

  @override
  _DrivesListPageState createState() => _DrivesListPageState();
}

class _DrivesListPageState extends State<DrivesListPage> {
  String filterText = '';
  Stream<QuerySnapshot>? filteredDrives;

  @override
  void initState() {
    super.initState();
    _fetchAllDrives();
  }

  void _fetchAllDrives() {
    setState(() {
      filteredDrives = FirebaseFirestore.instance
          .collection('ongoing_drives')
          .snapshots();
    });
  }

  void _filterDrives(String query) {
    if (query.isEmpty) {
      _fetchAllDrives();
    } else {
      setState(() {
        filteredDrives = FirebaseFirestore.instance
            .collection('ongoing_drives')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drives List'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Company Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filterText = value.trim();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _filterDrives(filterText);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filteredDrives,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No drives found.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['name']),
                      subtitle: Text(doc['description']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DriveDetailsPage(documentId: doc.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class DriveDetailsPage extends StatefulWidget {
  final String documentId;

  const DriveDetailsPage({super.key, required this.documentId});

  @override
  _DriveDetailsPageState createState() => _DriveDetailsPageState();
}

class _DriveDetailsPageState extends State<DriveDetailsPage> {
  String? name;
  String? description;
  String? pdfLink;
  String? applyLink;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDriveDetails();
  }

  Future<void> _fetchDriveDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ongoing_drives')
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'];
          description = doc['description'];
          pdfLink = doc['pdfLink'];
          applyLink = doc['link'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drive details not found.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Details'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null)
              Text(
                name!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            const SizedBox(height: 16),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 16),
            if (pdfLink != null && pdfLink!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _launchURL(pdfLink!),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('View PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            const SizedBox(height: 16),
            if (applyLink != null && applyLink!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Link:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _launchURL(applyLink!),
                    child: const Text('Open Application Link'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ],
              ),
            if ((pdfLink == null || pdfLink!.isEmpty) &&
                (applyLink == null || applyLink!.isEmpty))
              const Text('No links found.'),
          ],
        ),
      ),
    );
  }
}
