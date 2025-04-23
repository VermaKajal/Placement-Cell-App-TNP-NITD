import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final dynamic announcement; // Get the announcement passed from the previous page

  const AnnouncementDetailsPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final title = announcement['title'] ?? 'No Title';
    final company = announcement['company'] ?? 'No Company';
    final description = announcement['description'] ?? 'No Description';
    final ctc = announcement['ctc'] ?? 'Not Provided';
    final location = announcement['location'] ?? 'Not Provided';
    final applyLink = announcement['applyLink'] != null ? Uri.tryParse(announcement['applyLink']) : Uri.parse("https://google.com");

    return Scaffold(
      appBar: AppBar(
        title: Text(company),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Company: $company',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'CTC: $ctc',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: $location',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (applyLink != null) {
                  _openLink(context, applyLink);
                }
              },
              child: const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, Uri? url) async {
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
