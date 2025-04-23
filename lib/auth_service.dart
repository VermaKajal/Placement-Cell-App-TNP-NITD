import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserDetails {
  final String uid;
  final String email;
  final String username;

  UserDetails({required this.uid, required this.email, required this.username});
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email, password, and username
  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Save username to Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
        });

        // Send email verification
        await user.sendEmailVerification();
        print('Verification email sent to $email');
      }

      return user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signIn(String usernameOrEmail, String password) async {
    try {
      // Check if the input is an email
      if (RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(usernameOrEmail)) {
        // Sign in with email
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: usernameOrEmail,
          password: password,
        );
        return userCredential.user;
      } else {
        // If it's a username, fetch the user data from Firestore
        QuerySnapshot userSnapshot = await _firestore.collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          // Check if userDoc.data() is not null and cast it to Map<String, dynamic>
          final data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('email')) {
            String email = data['email'];

            // Now sign in with the retrieved email
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            return userCredential.user;
          } else {
            print('Email field does not exist for the username: $usernameOrEmail');
          }
        } else {
          print('User not found with the given username: $usernameOrEmail');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication exceptions
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print('Error signing in: ${e.message}');
      }
    } catch (e) {
      print('Error signing in: $e');
    }

    return null;
  }

  Future<UserDetails?> getUserByUsername(String username) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return UserDetails(
          uid: doc.id,
          email: doc['email'],
          username: doc['username'],
        );
      }
    } catch (e) {
      print('Error fetching user by username: $e');
    }
    return null; // Return null if not found or an error occurs
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  // Sign out user

  Future<void> signOut() async {
    // await _auth.signOut(); // Sign out from Firebase
    //await _googleSignIn.signOut(); // Sign out from Google
  }
}
Future<String?> getEmailFromUsername(String username) async {
  try {
    // Query Firestore for the user document where the username matches the provided username
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)  // Limit to one result since usernames should be unique
        .get();

    // If a matching user document is found, return the email from that document
    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      // Check if userDoc.data() is not null and contains the email field
      final data = userDoc.data() as Map<String, dynamic>?; // Cast to a map
      if (data != null && data.containsKey('email')) {
        return data['email'];  // Return the email if it exists
      } else {
        print('Email field does not exist in the document.');
        return null;
      }
    } else {
      // If no matching document is found, return null
      print('No user found with the username: $username');
      return null;
    }
  } catch (e) {
    print('Error fetching email for username "$username": $e');
    return null;
  }
}
