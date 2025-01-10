import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PremiumPage extends StatefulWidget {
  final String userId;

  const PremiumPage({super.key, required this.userId});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool isPaid = false;
  bool isLoading = false;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> subscriptionStream;

  static const bool isLocal = false;
  static const String localApiUrl = 'http://127.0.0.1:5001/fitopia-42331/us-central1/api';
  static const String productionApiUrl = 'https://us-central1-fitopia-42331.cloudfunctions.net/api';

  String getApiUrl() {
    return isLocal ? localApiUrl : productionApiUrl;
  }

  @override
  void initState() {
    super.initState();

    subscriptionStream = FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.userId)
        .snapshots();

    subscriptionStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          setState(() {
            isPaid = data['isPremium'] ?? false;
          });
        }
      }
    });
  }

 Future<void> createCustomerIfNeeded() async {
  try {
    final customerDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.userId)
        .get();

    if (customerDoc.exists && customerDoc.data()?['stripeId'] != null) {
      print('Customer already exists with Stripe ID: ${customerDoc.data()?['stripeId']}');
      return;
    }

    final url = Uri.parse('${getApiUrl()}/create-customer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': FirebaseAuth.instance.currentUser?.email,
        'userId': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final stripeId = responseData['customer']['id'];
      await FirebaseFirestore.instance.collection('customers').doc(widget.userId).set({
        'stripeId': stripeId,
        'isPremium': false,
      }, SetOptions(merge: true));
    } else {
      throw Exception('Failed to create customer: ${response.body}');
    }
  } catch (e) {
    print('Error during createCustomerIfNeeded: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create customer: $e')),
    );
  }
}

  Future<void> processSubscription() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Ensure the customer is created before proceeding
    await createCustomerIfNeeded();

    // Retrieve the customer ID from Firestore
    final customerDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.userId)
        .get();

    if (!customerDoc.exists || customerDoc.data()?['stripeId'] == null) {
      throw Exception("Customer ID not found. Ensure customer creation succeeds.");
    }

    final customerId = customerDoc.data()?['stripeId'];
    print("Retrieved Customer ID: $customerId");

    // Call the backend to create a subscription
    final url = Uri.parse('${getApiUrl()}/create-subscription');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customerId': customerId,
        'priceId': "price_1QeiMHR3km1Wsl68wd7wO6lh",
      }),
    );

    // Handle the response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final clientSecret = data['clientSecret'];

      print("Received client secret for Payment Intent: $clientSecret");

      // Initialize the Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fitopia Premium',
        ),
      );

      // Present the Payment Sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // Update Firestore with subscription status
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.userId)
          .update({'isPremium': true});

      setState(() {
        isPaid = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } else {
      throw Exception('Failed to create Payment Intent: ${response.body}');
    }
  } catch (e) {
    // Catch any errors during the subscription process
    print('Error during payment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $e')),
    );
  } finally {
    // Reset the loading state
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
              : SingleChildScrollView(
                  child: Padding(
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
                          onTap: () => processSubscription(),
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
                ),
    );
  }
}
