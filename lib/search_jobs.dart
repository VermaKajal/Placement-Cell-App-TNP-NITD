import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final DatabaseReference _offCampusRef =
  FirebaseDatabase.instance.ref('announcements').child('Offcampus');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jobs and Opportunities',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
        stream: _offCampusRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value;

            if (data is List) {
              return _buildAnnouncementList(data);
            } else if (data is Map) {
              final announcements = data.values.toList();
              return _buildAnnouncementList(announcements);
            } else {
              return const Center(
                  child: Text('No Off-Campus announcements available'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildAnnouncementList(List<dynamic> announcements) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        if (announcement != null) {
          final applyUri = announcement['applyLink'] != null
              ? Uri.tryParse(announcement['applyLink'])
              : Uri.parse("https://google.com");
          return Column(
            children: [
              const SizedBox(height: 10),
              _buildOpportunityCard(
                title: announcement['title'] ?? 'No Title',
                company: announcement['company'] ?? 'No Company',
                tag: announcement['tag'] ?? 'No Tag',
                logoPath: announcement['logopath'] ?? '',
                applyLink: applyUri,
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOpportunityCard({
    required String title,
    required String company,
    required String tag,
    required String logoPath,
    Uri? applyLink,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: logoPath.isNotEmpty
              ? NetworkImage(logoPath)
              : const AssetImage('assets/images/deshaw.png') as ImageProvider,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(company),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.orange[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            tag,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        onTap: () {
          _openLink(applyLink);
        },
      ),
    );
  }

  Future<void> _openLink(Uri? url) async {
    if (url != null) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication); // Open in browser
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
    }
  }
}
