import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacementStatisticsPage extends StatefulWidget {
  const PlacementStatisticsPage({Key? key}) : super(key: key);

  @override
  _PlacementStatisticsPageState createState() =>
      _PlacementStatisticsPageState();
}

class _PlacementStatisticsPageState extends State<PlacementStatisticsPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _studentsRef =
  FirebaseDatabase.instance.ref('placed').child('Btech');
  final DatabaseReference _barRef =
  FirebaseDatabase.instance.ref('database').child('BTech');
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> placements = [];
  // Overall Statistics
  int placedCount = 0;
  int notPlacedCount = 0;
  double placedPercentage = 0.0;
  double notPlacedPercentage = 0.0;
  int onCampusCount = 0;
  int offCampusCount = 0;

  // Branch-wise Statistics
  Map<String, Map<String, int>> branchPlacement = {
    'CSE': {'placed': 0, 'notPlaced': 0},
    'ECE': {'placed': 0, 'notPlaced': 0},
    'EEE': {'placed': 0, 'notPlaced': 0},
  };
  Map<String, Map<String, double>> branchPercentage = {
    'CSE': {'placed': 0.0, 'notPlaced': 0.0},
    'ECE': {'placed': 0.0, 'notPlaced': 0.0},
    'EEE': {'placed': 0.0, 'notPlaced': 0.0},
  };

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentData();
    _fetchPlacementData();
  }

  Future<void> _fetchStudentData() async {
    _studentsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> loadedStudents = [];

      if (data is List) {
        for (var student in data) {
          if (student != null) {
            loadedStudents.add({
              'isPlaced': _parseIsPlaced(student['IsPlaced']),
              'branch': _parseBranch(student['Branch']),
            });
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          loadedStudents.add({
            'isPlaced': _parseIsPlaced(value['IsPlaced']),
            'branch': _parseBranch(value['Branch']),
          });
        });
      }

      setState(() {
        students = loadedStudents;
        _calculatePlacementStatistics();
      });
    }).onError((error) {
      // Handle errors gracefully
      print('Error fetching data: $error');
      setState(() {
        students = [];
        placedCount = 0;
        notPlacedCount = 0;
        placedPercentage = 0.0;
        notPlacedPercentage = 0.0;
        branchPlacement = {
          'CSE': {'placed': 0, 'notPlaced': 0},
          'ECE': {'placed': 0, 'notPlaced': 0},
          'EEE': {'placed': 0, 'notPlaced': 0},
        };
        branchPercentage = {
          'CSE': {'placed': 0.0, 'notPlaced': 0.0},
          'ECE': {'placed': 0.0, 'notPlaced': 0.0},
          'EEE': {'placed': 0.0, 'notPlaced': 0.0},
        };
      });
    });
  }

  String _parseOnOffCampus(dynamic value) {
    return value?.toString() ?? 'Unknown';
  }
  // Fetch placement data from Firebase
  Future<void> _fetchPlacementData() async {
    _barRef.onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> loadedPlacements = [];

      if (data is List) {
        for (var placement in data) {
          if (placement != null) {
            loadedPlacements.add({
              'onOffCampus': _parseOnOffCampus(placement['On_Off_campus']),
              // Add other fields if necessary (e.g., 'company', 'CTC', etc.)
            });
          }
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          loadedPlacements.add({
            'onOffCampus': _parseOnOffCampus(value['On_Off_campus']),
            // Add other fields if necessary
          });
        });
      }

      // Update placements list
      setState(() {
        placements = loadedPlacements;
      });

      // Calculate on-campus and off-campus counts after fetching the data
      _calculateOnOffCampusPlacementStats();
    }).onError((error) {
      // Handle errors gracefully
      print('Error fetching placement data: $error');
      setState(() {
        placements = [];  // Clear placements list on error
        onCampusCount = 0;  // Reset on-campus count on error
        offCampusCount = 0;  // Reset off-campus count on error
      });
    });
  }



// Helper method to parse 'IsPlaced' field
  bool _parseIsPlaced(dynamic isPlacedValue) {
    if (isPlacedValue == null) return false;
    String value = isPlacedValue.toString().toLowerCase().trim();
    return value == 'true' || value == 'yes' || value == '1';
  }

// Helper method to parse 'Branch' field
  String _parseBranch(dynamic branchValue) {
    if (branchValue == null) return 'UNKNOWN';
    return branchValue.toString().toUpperCase().trim();
  }
  // Function to calculate on-campus and off-campus placement statistics
  void _calculateOnOffCampusPlacementStats() {
    // Reset counts
    onCampusCount = 0;
    offCampusCount = 0;

    // Calculate counts
    for (var placement in placements) {
      String onOffCampus = placement['On_Off_campus'];

      // Count on-campus and off-campus placements
      if (onOffCampus == 'On') {
        onCampusCount++;
      } else if (onOffCampus == 'Off') {
        offCampusCount++;
      }
    }

    // You can update the UI or trigger other calculations here if necessary
    setState(() {
      // Optionally, update other UI components based on the calculated counts
      // For example, you can update UI elements like a bar chart or text displaying the counts
    });
  }

  void _calculatePlacementStatistics() {
    // Reset counts
    placedCount = 0;
    notPlacedCount = 0;
    branchPlacement.forEach((branch, counts) {
      branchPlacement[branch]!['placed'] = 0;
      branchPlacement[branch]!['notPlaced'] = 0;
    });

    // Calculate counts
    for (var student in students) {
      String branch = student['branch'];
      bool isPlaced = student['isPlaced'];

      // Overall counts
      if (isPlaced) {
        placedCount++;
      } else {
        notPlacedCount++;
      }

      // Branch-wise counts
      if (branchPlacement.containsKey(branch)) {
        if (isPlaced) {
          branchPlacement[branch]!['placed'] = branchPlacement[branch]!['placed']! + 1;
        } else {
          branchPlacement[branch]!['notPlaced'] = branchPlacement[branch]!['notPlaced']! + 1;
        }
      }
    }

    // Calculate overall percentages
    int totalStudents = placedCount + notPlacedCount;
    if (totalStudents > 0) {
      placedPercentage = (placedCount / totalStudents) * 100;
      notPlacedPercentage = (notPlacedCount / totalStudents) * 100;
    } else {
      placedPercentage = 0.0;
      notPlacedPercentage = 0.0;
    }

    // Calculate branch-wise percentages
    branchPlacement.forEach((branch, counts) {
      int branchTotal = counts['placed']! + counts['notPlaced']!;
      if (branchTotal > 0) {
        branchPercentage[branch]!['placed'] = (counts['placed']! / branchTotal) * 100;
        branchPercentage[branch]!['notPlaced'] = (counts['notPlaced']! / branchTotal) * 100;
      } else {
        branchPercentage[branch]!['placed'] = 0.0;
        branchPercentage[branch]!['notPlaced'] = 0.0;
      }
      // Debugging: Print branch statistics
      print('$branch - Placed: ${counts['placed']}, '
          'Not Placed: ${counts['notPlaced']}, '
          'Placed %: ${branchPercentage[branch]!['placed']}%, '
          'Not Placed %: ${branchPercentage[branch]!['notPlaced']}%');
    });

    // Debugging: Print overall statistics
    print('Overall - Placed: $placedCount, Not Placed: $notPlacedCount, '
        'Placed %: $placedPercentage%, Not Placed %: $notPlacedPercentage%');
  }





  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBarChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Reduced horizontal padding
      child: BarChart(
        BarChartData(
          maxY: (onCampusCount > offCampusCount ? onCampusCount : offCampusCount) + 10,  // Dynamic Y-axis scaling
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,  // Adjust interval for Y-axis to fit better
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),  // Adjust font size for Y-axis
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('On-Campus', style: const TextStyle(fontSize: 12));  // Smaller text for X-axis labels
                    case 1:
                      return Text('Off-Campus', style: const TextStyle(fontSize: 12));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: onCampusCount.toDouble(),
                  width: 15,  // Adjusted bar width for better fit
                  color: Colors.blue,
                )
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: offCampusCount.toDouble(),
                  width: 15,  // Adjusted bar width for better fit
                  color: Colors.red,
                )
              ],
              showingTooltipIndicators: [0],
            ),
          ],
        ),
      ),
    );
  }

// Widget to build Overall Placement Section
  Widget _buildOverallPlacement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Placement Statistics',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildPieChart(
              placedPercentage, notPlacedPercentage, 'Overall'),
          const SizedBox(height: 10),
          _buildOverallPlacementDetails(),
        ],
      ),
    );
  }

// Widget to display Overall Placement Details
  Widget _buildOverallPlacementDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Placed: $placedCount (${placedPercentage.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Not Placed: $notPlacedCount (${notPlacedPercentage.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

// Widget to build Branch-wise Placement Section
  Widget _buildBranchPlacement(String branch, double placedPerc, double notPlacedPerc, int placedCountBranch, int notPlacedCountBranch) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$branch Placement Statistics',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPieChart(
                    placedPerc, notPlacedPerc, branch),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildBranchPlacementDetails(branch, placedCountBranch, notPlacedCountBranch, placedPerc, notPlacedPerc),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Widget to display Branch-wise Placement Details
  Widget _buildBranchPlacementDetails(String branch, int placed, int notPlaced, double placedPerc, double notPlacedPerc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Placed: $placed (${placedPerc.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Not Placed: $notPlaced (${notPlacedPerc.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TNP NITD', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Statistics"),
            Tab(text: "On/Off Campus"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildBarChart(),
        ],
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Placement Statistics'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: BarChart(
  //         BarChartData(
  //           borderData: FlBorderData(show: false),
  //           titlesData: FlTitlesData(
  //             leftTitles: AxisTitles(
  //               sideTitles: SideTitles(showTitles: true, interval: 10),
  //             ),
  //             bottomTitles: AxisTitles(
  //               sideTitles: SideTitles(
  //                 showTitles: true,
  //                 getTitlesWidget: (double value, TitleMeta meta) {
  //                   final labels = ['On Campus', 'Off Campus'];
  //                   return Text(labels[value.toInt()]);
  //                 },
  //               ),
  //             ),
  //           ),
  //           barGroups: [
  //             BarChartGroupData(
  //               x: 0,
  //               barRods: [BarChartRodData(toY: onCampusCount.toDouble(), color: Colors.blue)],
  //             ),
  //             BarChartGroupData(
  //               x: 1,
  //               barRods: [BarChartRodData(toY: offCampusCount.toDouble(), color: Colors.green)],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //

// Build the Statistics Tab
  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'On-Campus vs Off-Campus Placements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // Display bar chart
          _buildBarChart(),
          SizedBox(height: 20),
          // Display counts (Optional)
          Text(
            'On-Campus Count: $onCampusCount',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Off-Campus Count: $offCampusCount',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

// Build the Top Offers Tab



  // Build the Statistics Tab
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Overall Placement Statistics
          _buildPieChart(
              placedPercentage, notPlacedPercentage, 'Overall'),
          const SizedBox(height: 20),
          // CSE Placement Statistics
          _buildPieChart(
              branchPercentage['CSE']!['placed']!,
              branchPercentage['CSE']!['notPlaced']!,
              'CSE'),
          const SizedBox(height: 20),
          // ECE Placement Statistics
          _buildPieChart(
              branchPercentage['ECE']!['placed']!,
              branchPercentage['ECE']!['notPlaced']!,
              'ECE'),
          const SizedBox(height: 20),
          // EEE Placement Statistics
          _buildPieChart(
              branchPercentage['EEE']!['placed']!,
              branchPercentage['EEE']!['notPlaced']!,
              'EEE'),
          const SizedBox(height: 20),
          // Display Counts and Percentages
          _buildPlacementDetails(),
        ],
      ),
    );
  }

  // Widget to build a Pie Chart with given percentages and title
  Widget _buildPieChart(
      double placedPerc, double notPlacedPerc, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Text(
            '$title Placement Statistics',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(placedPerc, notPlacedPerc),
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 0, // 0 for a full pie chart
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Placed: ${placedPerc.toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Not Placed: ${notPlacedPerc.toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Define the sections for the pie chart based on percentages
  List<PieChartSectionData> _buildPieChartSections(
      double placedPerc, double notPlacedPerc) {
    return [
      PieChartSectionData(
        value: placedPerc,
        color: Colors.green,
        title: '${placedPerc.toStringAsFixed(2)}%',
        radius: 100, // Adjusted radius for better layout
        titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      PieChartSectionData(
        value: notPlacedPerc,
        color: Colors.red,
        title: '${notPlacedPerc.toStringAsFixed(2)}%',
        radius: 100, // Adjusted radius for better layout
        titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
    ];
  }

  // Widget to display counts and percentages
  Widget _buildPlacementDetails() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Overall Placement Details',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Placed: $placedCount (${placedPercentage.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Not Placed: $notPlacedCount (${notPlacedPercentage.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
      ],
    );
  }


  Widget _buildTopPlacementTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'On-Campus ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$onCampusCount',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Off-Campus',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$offCampusCount',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
                  backgroundImage: AssetImage(student['image']),
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
                    // Open LinkedIn link
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
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On-Campus Count: $onCampusCount',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Off-Campus Count: $offCampusCount',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  // Launch LinkedIn URL
  void _launchLinkedIn(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle the error gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
