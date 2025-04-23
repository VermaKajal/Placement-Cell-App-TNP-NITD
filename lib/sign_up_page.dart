import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/bezierContainer.dart';
import 'login_page.dart';
import 'auth_service.dart'; // Ensure you have imported your auth service

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.title});

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      _validateEmail();
    }
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    setState(() {
      if (email.isEmpty || !emailRegex.hasMatch(email)) {
        _emailError = 'Enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }


  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    } else if (value != value.toLowerCase()) {
      return 'Username must be in lowercase';
    }
    return null;
  }



  Widget _entryField(String title,
      {bool isPassword = false,
        required TextEditingController controller,
        String? Function(String?)? validator,
        FocusNode? focusNode,
        String? errorText}) {
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
            obscureText: isPassword,
            validator: validator,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: const Color(0xfff3f3f4),
              filled: true,
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          String email = _emailController.text;
          String password = _passwordController.text;
          String username = _usernameController.text;

          final authService = Provider.of<FirebaseAuthService>(context, listen: false);

          // Sign up and send verification email
          User? user = await authService.signUpWithEmailAndPassword(email, password, username);

          if (user != null) {
            // Navigate to the login page or show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
            );

            // Optionally navigate to the Login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error during sign up. Please try again.')),
            );
          }
        }
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
            )
          ],
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)],
          ),
        ),
        child: const Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _entryField(
            "Username",
            controller: _usernameController,
            validator: _usernameValidator, // Use the validator
          ),
          _entryField(
            "Email id",
            controller: _emailController,
            focusNode: _emailFocusNode,
            errorText: _emailError,
          ),
          _entryField(
            "Password",
            isPassword: true,
            controller: _passwordController,
            validator: _passwordValidator,
          ),
        ],
      ),
    );
  }


  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 8 || value.length > 12) {
      return 'Password must be between 8 and 12 characters long';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }


  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'T',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xffe46b10),
        ),
        children: [
          TextSpan(
            text: 'np',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: ' NITD',
            style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: const <Widget>[
          Icon(Icons.arrow_back, color: Colors.black),
          SizedBox(width: 10),
          Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: const Text(
        'Already have an account? Login',
        style: TextStyle(
          color: Color(0xffe46b10),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(height: 50),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
