import 'package:flutter/material.dart';
import 'addreport.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportDetailPage.dart';
class ReportGenerationPage extends StatefulWidget {
  const ReportGenerationPage({super.key});

  @override
  _ReportGenerationPageState createState() => _ReportGenerationPageState();
}

class _ReportGenerationPageState extends State<ReportGenerationPage> {
  final List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final snapshot = await FirebaseFirestore.instance.collection('reports').get();
    final reportsData = snapshot.docs.map((doc) {
      return doc.data()..['id'] = doc.id; // Optionally store the document ID
    }).toList();

    setState(() {
      reports.addAll(reportsData);
    });
  }

  void addReport(Map<String, dynamic> report) {
    setState(() {
      reports.add(report);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Generation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: reports.isEmpty
                  ? const Center(
                child: Text(
                  "No reports available. Click 'Add New Report' to create one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReportDetailPage(report: report),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          report["companyName"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        subtitle: Text(report["description"]),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final newReport = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReportPage(),
                  ),
                );

                if (newReport != null) {
                  addReport(newReport);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add New Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
