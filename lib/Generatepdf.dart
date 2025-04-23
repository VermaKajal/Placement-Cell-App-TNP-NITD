import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:docx_template/docx_template.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class GenerateReportPage extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const GenerateReportPage({super.key, required this.reportData});

  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  String selectedFormat = 'PDF';  // Default format

  Future<void> generateReport(String format, BuildContext context) async {
    try {
      if (format == 'PDF') {
        await generatePDF(context);
      } else if (format == 'CSV') {
        await generateCSV(context);
      } else if (format == 'DOC') {
        //await generateDOC(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Company Report",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.Divider(),
              pw.Text("Company Name: ${widget.reportData['companyName']}"),
              pw.Text("Description: ${widget.reportData['description']}"),
              pw.Text("Start Date: ${widget.reportData['startDate']}"),
              pw.Text("End Date: ${widget.reportData['endDate']}"),
              pw.Text("Eligible Branches: ${widget.reportData['branches']}"),
              pw.Text("Registered Students File: ${widget.reportData['registeredStudentsFile'] ?? 'No file uploaded'}"),
              pw.SizedBox(height: 10),
              if (widget.reportData['rounds'] != null)
                pw.Text("Rounds: ${(widget.reportData['rounds'] as List).join(', ')}"),
              pw.SizedBox(height: 10),
              if (widget.reportData['registeredStudents'] != null)
                pw.Text(
                    "Registered Students: ${(widget.reportData['registeredStudents'] as List).join(', ')}"),
              pw.SizedBox(height: 10),
              if (widget.reportData['finalSelectedStudents'] != null)
                pw.Text(
                    "Final Selected Students: ${(widget.reportData['finalSelectedStudents'] as List).join(', ')}"),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());

    await uploadToFirebase(file);
  }

  Future<void> generateCSV(BuildContext context) async {
    List<List<dynamic>> rows = [
      ["Company Name", "Description", "Start Date", "End Date", "Eligible Branches", "Registered Students File"],
      [
        widget.reportData['companyName'],
        widget.reportData['description'],
        widget.reportData['startDate'],
        widget.reportData['endDate'],
        widget.reportData['branches'],
        widget.reportData['registeredStudentsFile'] ?? 'No file uploaded',
      ]
    ];

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/report.csv');
    await file.writeAsString(csvData);

    // Upload to Firebase Storage and save metadata to Firestore
    await uploadToFirebase(file);
  }

 // // Future<void> generateDOC(BuildContext context) async {
 //    final doc = await DocxTemplate.fromAsset('assets/template.docx');
 //
 //    doc.setAll({
 //      'companyName': widget.reportData['companyName'],
 //      'description': widget.reportData['description'],
 //      'startDate': widget.reportData['startDate'],
 //      'endDate': widget.reportData['endDate'],
 //      'branches': widget.reportData['branches'],
 //      'registeredStudentsFile': widget.reportData['registeredStudentsFile'] ?? 'No file uploaded',
 //    });
 //
 //    final bytes = await doc.save();
 //    final directory = await getApplicationDocumentsDirectory();
 //    final file = File('${directory.path}/report.docx');
 //    await file.writeAsBytes(bytes);
 //
 //    // Upload to Firebase Storage and save metadata to Firestore
 //    await uploadToFirebase(file);
 //  }

  Future<void> uploadToFirebase(File file) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('reports/${file.path.split('/').last}');
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('reports').add({
        'companyName': widget.reportData['companyName'], // Company Name
        'description': widget.reportData['description'], // Description
        'startDate': widget.reportData['startDate'], // Start Date
        'endDate': widget.reportData['endDate'], // End Date
        'branches': widget.reportData['branches'], // Eligible Branches
        'registeredStudentsFile': widget.reportData['registeredStudentsFile'], // Registered Students File
        'rounds': widget.reportData['rounds'] ?? [], // Rounds (ensure it's a list)
        'registeredStudents': widget.reportData['registeredStudents'] ?? [], // Registered Students (ensure it's a list)
        'finalSelectedStudents': widget.reportData['finalSelectedStudents'] ?? [], // Final Selected Students (ensure it's a list)
        'pdfUrl': downloadUrl, // PDF URL (ensure downloadUrl is defined earlier)
        'timestamp': FieldValue.serverTimestamp(), // Server Timestamp
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report generated and uploaded!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading to Firebase: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Report"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedFormat,
              items: ['PDF', 'DOC', 'CSV']
                  .map((format) => DropdownMenuItem<String>(
                value: format,
                child: Text(format),
              ))
                  .toList(),
              onChanged: (String? newFormat) {
                setState(() {
                  selectedFormat = newFormat!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => generateReport(selectedFormat, context),
              child: const Text("Generate and Upload Report"),
            ),
          ],
        ),
      ),
    );
  }
}
