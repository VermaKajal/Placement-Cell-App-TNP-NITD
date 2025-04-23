import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSign extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? _googleUser;
  User? _user;

  GoogleSignInAccount? get googleUser => _googleUser;
  User? get user => _user;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
     // await _googleSignIn.disconnect();
     // await _googleSignIn.signOut();
     // await _auth.signOut();

    final googleCurrentUser = _auth.currentUser;
    if (googleCurrentUser != null) {
      _googleSignIn.signOut();
      await _auth.signOut();
    }
    _user = null;
    notifyListeners();
    await _googleSignIn.disconnect();
  }
}
