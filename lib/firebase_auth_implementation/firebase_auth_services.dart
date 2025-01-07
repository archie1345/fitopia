import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitopia/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up a new user using email and password, and set their displayName.
  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      // Create a new user with email and password
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'User creation failed.',
        );
      }

      // Update displayName for the user
      await user.updateDisplayName(username);
      await user.reload();
      user = _firebaseAuth.currentUser;

      // Save user information to Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'username': username,
        'email': email,
        'uid': user.uid,
        'createdAt': Timestamp.now(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          showToast(message: 'The email address is already in use.');
          break;
        case 'weak-password':
          showToast(message: 'The password is too weak.');
          break;
        case 'invalid-email':
          showToast(message: 'Invalid email address.');
          break;
        default:
          showToast(message: 'FirebaseAuth error: ${e.message}');
      }
      print('FirebaseAuthException: ${e.code}, ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      showToast(message: 'An unexpected error occurred.');
    }
    return null;
  }

  /// Sign in an existing user with email and password.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          showToast(message: 'Invalid email or password.');
          break;
        default:
          showToast(message: 'An error occurred: ${e.message}');
      }
      print('FirebaseAuthException: ${e.code}, ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      showToast(message: 'An unexpected error occurred.');
    }
    return null;
  }

  /// Sign in using Google credentials.
Future<void> signInWithGoogle(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // Always merge or set data in Firestore to ensure email is saved
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? '',
          'email': user.email ?? 'N/A', // Ensure email is saved
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge data if the document exists
      }

      Navigator.pushNamed(context, "/home");
    }
  } catch (e) {
    print('Google Sign-In Error: $e');
    showToast(message: "An error occurred during Google Sign-In.");
  }
}


  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      showToast(message: "Successfully signed out.");
    } catch (e) {
      print('Sign-Out Error: $e');
      showToast(message: "Error signing out: $e");
    }
  }
}
