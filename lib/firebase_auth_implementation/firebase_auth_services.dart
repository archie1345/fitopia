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

  /// Create a new Stripe customer and save the ID to Firestore
  Future<void> createStripeCustomer(String userId, String email) async {
    try {
      // Validate the email
      if (email.isEmpty) {
        throw Exception("User email is missing.");
      }

      // Check Firestore for an existing Stripe customer ID
      final customerDoc = await _firestore.collection('customers').doc(userId).get();

      if (customerDoc.exists && customerDoc.data()?['stripeId'] != null) {
        print('Customer already exists with Stripe ID: ${customerDoc.data()?['stripeId']}');
        return; // Customer already exists, no further action required
      }

      // API URL for creating a Stripe customer
      final url = Uri.parse('https://us-central1-fitopia-42331.cloudfunctions.net/api/create-customer');

      // Call the backend API to create the customer
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Parse the API response
        final responseData = json.decode(response.body);
        final stripeId = responseData['customer']['id'];

        // Save the Stripe ID and default isPremium status to Firestore
        await _firestore.collection('customers').doc(userId).set({
          'stripeId': stripeId,
          'isPremium': false,
        }, SetOptions(merge: true));

        print('Stripe customer created successfully with ID: $stripeId');
      } else {
        // Handle errors from the backend API
        print('Error creating Stripe customer: ${response.body}');
        throw Exception('Failed to create Stripe customer: ${response.body}');
      }
    } catch (e) {
      // Handle unexpected errors
      print('Error during Stripe customer creation: $e');
      showToast(message: 'Failed to create Stripe customer.');
      rethrow;
    }
  }

  /// Sign up a new user with email and password
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
      await createStripeCustomer(user.uid, email);

      return user;
    } catch (e) {
      print('Error during signup: $e');
      rethrow;
    }
  }

  /// Handle FirebaseAuth exceptions
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
    print('FirebaseAuthException: ${e.code}, ${e.message}');
  }

  /// Sign in an existing user with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
    } catch (e) {
      print('Unexpected error: $e');
      showToast(message: 'An unexpected error occurred.');
    }
    return null;
  }

  /// Sign in using Google credentials
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        final user = userCredential.user;

        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? '',
            'email': user.email ?? 'N/A',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await createStripeCustomer(user.uid, user.email ?? "N/A");
          Navigator.pushNamed(context, "/home");
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      showToast(message: "An error occurred during Google Sign-In.");
    }
  }

  /// Sign out the current user
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
