import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/classes/subscriptionService.dart';
import 'package:fitopia/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<void> handleSignOut(BuildContext context) async {
    try {
      // Retrieve the current user's ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Stop subscription service if user ID is available
        final subscriptionService = SubscriptionService(userId: userId);
        subscriptionService.stopSubscriptionCheck();
      }

      // Sign out the user
      await FirebaseAuthService().signOut();

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } catch (e) {
      print("Error during sign-out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        surfaceTintColor: Colors.white,
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => handleSignOut(context),
                child: Container(
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(81, 75, 35, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserModel {
  final String? username;
  final String? address;
  final int? age;
  final String? id;

  UserModel({this.id, this.username, this.address, this.age});

  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return UserModel(
      username: snapshot['username'],
      address: snapshot['address'], // Corrected key 'adress' to 'address'
      age: snapshot['age'],
      id: snapshot['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "age": age,
      "id": id,
      "address": address, // Corrected key here too
    };
  }
}
