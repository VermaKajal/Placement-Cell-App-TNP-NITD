// login_page.dart

import 'dart:async';
import 'dart:math'; // For generating random numbers
import 'auth_service.dart'; // Your FirebaseAuthService
import 'package:flutter/material.dart';
import 'widgets/bezierContainer.dart'; // Custom widget for design
import 'google_sign_in.dart'; // Your GoogleSign provider
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'captcha_widget.dart'; // Your custom CAPTCHA widget

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.title});

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Service for Firebase Authentication
  final FirebaseAuthService _authService = FirebaseAuthService();

  // State variables
  bool _isCaptchaVerified = false; // Tracks CAPTCHA verification
  bool _isPasswordVisible = false; // Toggles password visibility

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Navigates back to the previous screen
  // Widget _backButton() {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.pop(context);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 10),
  //       child: Row(
  //         children: <Widget>[
  //           Container(
  //             padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
  //             child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
  //           ),
  //           const Text(
  //             'Back',
  //             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Custom entry field widget with validation
  Widget _entryField(
      String title,
      TextEditingController controller, {
        bool isPassword = false,
        String? Function(String?)? validator,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: const Color(0xfff3f3f4),
              filled: true,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
                  : null,
            ),
            validator: validator, // Use the validator parameter here
          ),
        ],
      ),
    );
  }

  /// CAPTCHA widget integrated into the login form
  Widget _captchaWidget() {
    return Column(
      children: [
        CaptchaWidget(
          onVerified: (bool success) {
            setState(() {
              _isCaptchaVerified = success;
            });
          },
        ),
        const SizedBox(height: 10),
        Text(
          _isCaptchaVerified ? 'CAPTCHA Verified' : 'Please complete the CAPTCHA',
          style: TextStyle(
            color: _isCaptchaVerified ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Submit button that triggers the login process
  Widget _submitButton() {
    return GestureDetector(
      onTap: _isCaptchaVerified
          ? () async {
        // Check if a user is already logged in
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already logged in.')),
          );
          Navigator.pushReplacementNamed(context, '/rolepage');
          return;
        }

        // Validate form fields
        if (_formKey.currentState?.validate() ?? false) {
          String input = _emailController.text.trim();
          String password = _passwordController.text.trim();
          final authService =
          Provider.of<FirebaseAuthService>(context, listen: false);

          String? email;
          if (RegExp(r'\S+@\S+\.\S+').hasMatch(input)) {
            email = input; // Input is an email
          } else {
            // Retrieve email from username
            email = await _getEmailFromUsername(input);

            if (email == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username not found')),
              );
              return;
            }
          }

          // Log the email being used for sign-in
          print('Attempting to sign in with email: $email');

          // Attempt to sign in
          User? user = await authService.signIn(email, password);

          if (user != null) {
            // Successfully signed in
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed in successfully.')),
            );
            Navigator.pushReplacementNamed(context, '/rolepage');
          } else {
            // Sign-in failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Error signing in. Please check your credentials.')),
            );
          }
        }
      }
          : () {
        // Inform the user to complete CAPTCHA
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Please complete the CAPTCHA before logging in.')),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
          gradient: _isCaptchaVerified
              ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)],
          )
              : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.grey, Colors.grey],
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  /// Retrieves the email associated with a given username from Firestore
  Future<String?> _getEmailFromUsername(String username) async {
    try {
      // Query Firestore for a document where the 'username' field matches the input
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a match is found, return the corresponding email
        return querySnapshot.docs.first['email'];
      } else {
        return null; // No matching username found
      }
    } catch (e) {
      print('Error getting email from username: $e');
      return null;
    }
  }

  /// Button for users to initiate password reset
  Widget _forgotPasswordButton() {
    return GestureDetector(
      onTap: () {
        _showForgotPasswordDialog();
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// Displays a dialog for users to enter their email for password reset
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Enter your email to receive a password reset link:'),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle password reset logic
                _resetPassword(emailController.text.trim());
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Send Reset Link'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Sends a password reset email to the provided email address
  void _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  /// Divider widget with "or" text
  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  /// Google Sign-In button
  Widget _googleSignInButton() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final provider =
          Provider.of<GoogleSign>(context, listen: false); // Your GoogleSign provider
          User? user = await provider.signInWithGoogle();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/rolepage'); // Navigate to role page
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error signing in with Google.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Removes default padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Matches container
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff1959a9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'G',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff2872ba),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Log in with Google',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label for creating a new account
  Widget _createAccountLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Don\'t have an account?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/sign_up'); // Navigate to SignUpPage
            },
            child: const Text(
              'Register',
              style: TextStyle(
                color: Color(0xfff79c4f),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Title widget for the login page
  Widget _title() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: 'TnP Cell',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10),
            ),
          ),
        ),
        const SizedBox(height: 10), // Add some space between the title and the subtitle
        const Text(
          'NIT Delhi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  /// Widget containing email/username and password fields
  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(
          "Username or Email",
          _emailController, // Use the email controller
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value) &&
                value.length < 3) {
              return 'Enter a valid username or email';
            }
            return null;
          },
        ),
        _entryField(
          "Password",
          _passwordController,
          isPassword: true, // Ensure this is set to true
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            if (value.length < 8 || value.length > 12) {
              return 'Password must be between 8 and 12 characters';
            }
            if (!RegExp(r'^(?=.*?[a-zA-Z])(?=.*?\d)(?=.*?[^\w\s]).+$')
                .hasMatch(value)) {
              return 'Password must contain at least one letter, one number, and one special character';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Main build method for the LoginPage
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            // Decorative Bezier container
            Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            // Main content container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Assign form key
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      _title(),
                      const SizedBox(height: 50),
                      _emailPasswordWidget(),
                      const SizedBox(height: 20),
                      _captchaWidget(), // CAPTCHA widget with verification
                      const SizedBox(height: 20),
                      _submitButton(), // Submit button disabled/enabled based on CAPTCHA
                      _forgotPasswordButton(),
                      _divider(),
                      _googleSignInButton(), // Google Sign-In button
                      SizedBox(height: height * .055),
                      _createAccountLabel(),
                    ],
                  ),
                ),
              ),
            ),
            // Back button positioned at the top-left corner
            //Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
