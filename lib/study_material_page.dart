import 'package:flutter/material.dart';

class StudyMaterialPage extends StatelessWidget {
  const StudyMaterialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Material'),
        backgroundColor: Colors.black, // Match the black theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Header section with a logo and subtitle
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const <Widget>[
                  Text(
                    'Study Materials',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Serving NITD',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid with study materials categories
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: <Widget>[
                  _buildStudyMaterialCard(
                    context,
                    'assets/images/books.png', // Add relevant image path
                    'DSA',
                  ),
                  _buildStudyMaterialCard(
                    context,
                    'assets/images/info.jpeg', // Add relevant image path
                    'Core Fundamentals',
                  ),
                  _buildStudyMaterialCard(
                    context,
                    'assets/images/reminder.png', // Add relevant image path
                    'Previous Questions',
                  ),
                  _buildStudyMaterialCard(
                    context,
                    'assets/images/calendars.png', // Add relevant image path
                    'Mock Interview',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Add navigation or actions when this button is clicked
            },
            child: const Text('Get ready for your placements!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
          ),
        ),
      ),
    );
  }

  // Reusable card widget for each category
  Widget _buildStudyMaterialCard(BuildContext context, String imagePath, String title) {
    return GestureDetector(
      onTap: () {
        // Add navigation or actions when card is tapped
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imagePath,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
