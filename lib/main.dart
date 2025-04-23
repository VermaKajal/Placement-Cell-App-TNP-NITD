import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:tnpnitd/announcement_page.dart';
import 'package:tnpnitd/rolepage.dart';
import 'package:tnpnitd/update_profile_page.dart';
import 'google_sign_in.dart';
import 'auth_service.dart';  // Ensure this service is properly defined in your project
import 'home_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'search_jobs.dart';
import 'after_signin.dart';
import 'profile_page.dart';
import 'study_material_page.dart';
import 'dart:async';
import 'placement_statistics.dart';
import 'Personal_Information.dart';
import 'providers/user_data_provider.dart';
import 'Availableresume.dart';
import 'Resumechecker.dart';
import 'rolepage.dart';
import 'Ongoingdrives.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,// For web, if you're using it
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GoogleSign()),
        Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/home_page': (context) => const HomePage(),
        '/announcements': (context) => AnnouncementPage(),
        '/profilepage': (context) => const ProfilePage(),
        '/aftersign': (context) => const AfterSignIn(),
        '/study_material': (context) => const StudyMaterialPage(),
        '/search_jobs': (context) => const Announce(),
        '/update_profile' : (context) => const UpdateProfilePage(),
        '/placement_statistics' : (context) => const PlacementStatisticsPage(),
        '/personal_information' : (context) => const PersonalInformationPage(),
        '/available_resume' : (context) => const AvailableResumePage(),
        '/resume_checker': (context) => const ResumeCheckerPage(),
        '/rolepage': (context) =>  RolePage(),
        '/ongoing_drives': (context) => const StudentOngoingDrivesPage(),




      },
    );
  }
}

  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     title: 'Flutter Demo',
  //     initialRoute: '/', // Set the initial route
  //     routes: {
  //       '/': (context) => const SplashScreen(),
  //       '/login': (context) => const LoginPage(), // Update route to '/login'
  //       '/sign_up': (context) => const SignUpPage(), // Add route for SignUpPage
  //       '/home_page': (context) => const HomePage(), // Add HomePage route
  //       '/announcements': (context) => const AnnouncementPage(),
  //       '/profilepage' : (context) => const ProfilePage(),
  //       '/aftersign' : (context) => const AfterSignIn(),
  //     },


    //);



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay before navigating to the login screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Customize the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo1.png', // Your image path
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'TnP NIT Delhi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
