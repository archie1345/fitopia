import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitopia/widget/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   // Create a new Stripe customer and save the ID to Firestore
  Future<void> createStripeCustomer(String userId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        debugPrint("Error: User is not signed in.");
        throw Exception("User is not signed in.");
      }

      // Force refresh the token to ensure it's not stale
      final idToken = await currentUser.getIdToken(true);
      final email = currentUser.email;
      final username = currentUser.displayName ?? currentUser.email;

      final response = await http.post(
        Uri.parse("https://api-3fhkguk6lq-uc.a.run.app/create-customer"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "email": email,
          "username": username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Stripe customer created: $data");

        await FirebaseFirestore.instance.collection('customers').doc(userId).set({
          'stripeId': data['customerId'],
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        debugPrint('Failed to create Stripe customer: ${response.body}');
        throw Exception('Failed to create Stripe customer');
      }
    } catch (e) {
      debugPrint('Error creating Stripe customer: $e');
      throw Exception('Failed to create Stripe customer');
    }
  }




// Sign up a new user
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'User creation failed.',
        );
      }

      // Save user to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'username': username,
        'uid': user.uid,
        'createdAt': Timestamp.now(),
      });

      // Create a Stripe Customer
      // await createStripeCustomer(user.uid, email, username);

      return user;
    } catch (e) {
      debugPrint('Error during signup: $e');
      rethrow;
    }
  }

  // Handle FirebaseAuth exceptions
  void handleAuthException(FirebaseAuthException e) {
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
    debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
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
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      showToast(message: 'An unexpected error occurred.');
    }
    return null;
  }

Future<void> signInWithGoogle(BuildContext context) async {
  try{

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
        showToast(message: "Google Sign-In was canceled.");
        return;
      }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);

    // Once signed in, return the UserCredential
    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user;
    if (user != null) {
    // await createStripeCustomer(
    //   user.uid,
    //   user.email ?? '',
    //   user.displayName ?? user.uid, // use displayName or fallback to uid
    // );

      // Always merge or set data in Firestore to ensure email is saved
      await _firestore.collection('users').doc(user.uid).set({
        'username': user.displayName ?? '',
        'email': user.email ?? 'N/A', // Ensure email is saved
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge data if the document exists
    }

      Navigator.pushNamed(context, "/home");
  } on FirebaseAuthException catch (e) {
      showToast(message: "Firebase Auth Error: ${e.message}");
      debugPrint('Firebase Auth Error: $e');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      showToast(message: "An unexpected error occurred during Google Sign-In.");
  }
}

void onUserLogin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // await createStripeCustomer(
    //   user.uid,
    //   user.email ?? '',
    //   user.displayName ?? user.uid,
    // );
  }
}

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      showToast(message: "Successfully signed out.");
    } catch (e) {
      debugPrint('Sign-Out Error: $e');
      showToast(message: "Error signing out: $e");
    }
  }
}
