import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumPage extends StatefulWidget {
  final String userId; // User ID from Firebase Authentication
  const PremiumPage({super.key, required this.userId});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool isPaid = false;
  bool isLoading = false;

  static const String ApiUrl = "https://api-3fhkguk6lq-uc.a.run.app";

  @override
  void initState() {
    super.initState();
    checkSubscriptionStatus(); // Check subscription status on page load
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      if (widget.userId.isEmpty) {
        throw Exception("User ID is missing.");
      }

      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.userId)
          .get();

      if (customerDoc.exists && customerDoc['isPremium'] == true) {
        setState(() {
          isPaid = true;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error checking subscription status: $e');
    }
  }

  Future<void> processSubscription() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.userId.isEmpty) {
        throw Exception("User ID is missing.");
      }

      
      final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

      final response = await http.post(
      Uri.parse('$ApiUrl/create-subscription'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode({
        'priceId': 'price_1QeiMHR3km1Wsl68wd7wO6lh',
      }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create subscription: ${response.body}');
      }

      final data = json.decode(response.body);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Fitopia Premium',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.userId)
          .update({'isPremium': true});

      setState(() {
        isPaid = true;
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error during subscription: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Subscription Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Premium',
          style: TextStyle(
            color: Color(0xFF656839),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isPaid
          ? const Center(
              child: Text(
                "You are already a Premium Member!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ready to transform your body and reach its peak?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "BENEFITS USING PREMIUM:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "FREE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Access limited features and basic functionalities.",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: processSubscription,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(81, 75, 35, 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "PREMIUM",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Unlock exclusive features and personalized plans.",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Click below to upgrade now!",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white70),
                                  ),
                                  Text(
                                    "UPGRADE",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
