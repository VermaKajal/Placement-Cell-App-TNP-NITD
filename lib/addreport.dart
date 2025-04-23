import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'Generatepdf.dart'; // Ensure this is the correct import path

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  _AddReportPageState createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController branchesController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();  // New controller for rounds
  String? registeredStudentsFile;

  // Controllers for Registered Students and Final Selected Students
  List<String> registeredStudents = [];
  List<String> finalSelectedStudents = [];

  List<TextEditingController> roundControllers = [];  // List of controllers for round details

  // This method will update the number of rounds dynamically
  void updateRounds(int numberOfRounds) {
    setState(() {
      roundControllers = List.generate(numberOfRounds, (index) {
        return TextEditingController(); // Create a new controller for each round's details
      });
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        registeredStudentsFile = result.files.single.name; // Display file name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Report'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the start date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the end date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: branchesController,
                  decoration: const InputDecoration(
                    labelText: 'Eligible Branches',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter eligible branches';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Registered Students Section
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Registered Student',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        registeredStudents.add(value);
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Add a field for the number of rounds
                TextFormField(
                  controller: roundsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Rounds',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of rounds';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Update the rounds dynamically when the value changes
                    int? rounds = int.tryParse(value);
                    if (rounds != null && rounds > 0) {
                      updateRounds(rounds);
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Display the round input fields dynamically
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: roundControllers.length,
                  itemBuilder: (context, index) {
                    return TextFormField(
                      controller: roundControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Round ${index + 1} Details',
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),


                const SizedBox(height: 10),
                // Display Registered Students List
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: registeredStudents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(registeredStudents[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            registeredStudents.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Final Selected Students Section
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Final Selected Student',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        finalSelectedStudents.add(value);
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        registeredStudentsFile ?? "No file chosen",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: pickFile,
                      child: const Text("Upload File"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Display Final Selected Students List
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: finalSelectedStudents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(finalSelectedStudents[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            finalSelectedStudents.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenerateReportPage(
                            reportData: {
                              "companyName": companyNameController.text,
                              "description": descriptionController.text,
                              "startDate": startDateController.text,
                              "endDate": endDateController.text,
                              "branches": branchesController.text,
                              "registeredStudentsFile": registeredStudentsFile,
                              "rounds": List.generate(
                                roundControllers.length,
                                    (index) => roundControllers[index].text,
                              ),
                              "registeredStudents": registeredStudents,
                              "finalSelectedStudents": finalSelectedStudents,
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Generate Report"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
