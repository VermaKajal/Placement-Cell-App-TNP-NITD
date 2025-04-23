import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tnpnitd/home_page.dart';
import 'package:tnpnitd/login_page.dart';


class AfterSignIn extends StatelessWidget {
  const AfterSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return HomePage();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Something Went Wrong'),
            );
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}