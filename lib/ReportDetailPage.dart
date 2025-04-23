import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({required this.report, super.key});

  // Method to launch the URL for download
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report["companyName"] ?? "Report Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display basic fields
              Text(
                "Company Name: ${report["companyName"]}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Description: ${report["description"] ?? "N/A"}"),
              const SizedBox(height: 8),
              Text("Start Date: ${report["startDate"] ?? "N/A"}"),
              const SizedBox(height: 8),
              Text("End Date: ${report["endDate"] ?? "N/A"}"),
              const SizedBox(height: 8),
              Text("Eligible Branches: ${report["branches"] ?? "N/A"}"),
              const SizedBox(height: 8),
              Text(
                  "Registered Students File: ${report["registeredStudentsFile"] ?? "No file uploaded"}"),
              const SizedBox(height: 16),

              // Display rounds
              if (report["rounds"] != null && (report["rounds"] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rounds:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (report["rounds"] as List).length,
                          (index) => Text(
                        "- Round ${index + 1}: ${(report["rounds"] as List)[index]}",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Display registered students
              if (report["registeredStudents"] != null &&
                  (report["registeredStudents"] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Registered Students:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (report["registeredStudents"] as List).length,
                          (index) => Text(
                        "- ${(report["registeredStudents"] as List)[index]}",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Display final selected students
              if (report["finalSelectedStudents"] != null &&
                  (report["finalSelectedStudents"] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Final Selected Students:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (report["finalSelectedStudents"] as List).length,
                          (index) => Text(
                        "- ${(report["finalSelectedStudents"] as List)[index]}",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // File download buttons
              if (report['pdfUrl'] != null ||
                  report['csvUrl'] != null ||
                  report['docUrl'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report['pdfUrl'] != null)
                      ElevatedButton(
                        onPressed: () {
                          _launchURL(report['pdfUrl']);
                        },
                        child: const Text('Download PDF'),
                      ),
                    if (report['csvUrl'] != null)
                      ElevatedButton(
                        onPressed: () {
                          _launchURL(report['csvUrl']);
                        },
                        child: const Text('Download CSV'),
                      ),
                    if (report['docUrl'] != null)
                      ElevatedButton(
                        onPressed: () {
                          _launchURL(report['docUrl']);
                        },
                        child: const Text('Download DOC'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
