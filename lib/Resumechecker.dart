import 'package:flutter/material.dart';

class ResumeCheckerPage extends StatelessWidget {
  const ResumeCheckerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Checker'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 10, // Adds shadow to the AppBar
        toolbarHeight: 70, // Increases the height for a cleaner look
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ), // Adds a gradient background
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Ensures content is scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centers the content
            children: [
              // Quote added at the top
              const Text(
                '"A well-crafted resume is your first step towards success—make it shine, and the opportunities will follow."',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center, // Centers the quote
              ),
              const SizedBox(height: 30), // Adds more space below the quote

              _buildSectionCard(
                context,
                'assets/images/template.jpeg', // Replace with actual image path
                'Resume Templates',
                '/resume_templates', // Route to Resume Templates page
              ),
              const SizedBox(height: 30),
              _buildSectionCard(
                context,
                'assets/images/checker.jpeg', // Replace with actual image path
                'Score Checker',
                '/score_checker', // Route to Score Checker page
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String imagePath, String title, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName); // Navigate to respective page
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        elevation: 15, // Adds subtle shadow
        shadowColor: Colors.black.withOpacity(0.3), // Subtle shadow color
        color: Colors.white, // White background color for each card
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0), // Ensures the image is rounded within the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Added a container with a fixed height to ensure image size consistency
              Container(
                height: 150, // Fixed height to ensure the image fits properly
                width: double.infinity, // Make the image take up the full width
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Ensures the image fills the container without distortion
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adds horizontal padding for title
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // Set text color to black for contrast
                  ),
                  textAlign: TextAlign.center, // Centers the title text
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
