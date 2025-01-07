import 'package:fitopia/page/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumPage extends StatefulWidget {
  final String userId; // User ID from Firebase Authentication

  const PremiumPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool isPaid = false;
  bool isLoading = false; // For showing a loading spinner during payment

  @override
  void initState() {
    super.initState();
    checkSubscriptionStatus(); // Check subscription status on page load
  }

  // Function to check if the user already has a premium subscription
  Future<void> checkSubscriptionStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc['isPremium'] == true) {
        setState(() {
          isPaid = true;
        });

        // Redirect to the homepage if already subscribed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      }
    } catch (e) {
      print("Error checking subscription status: $e");
    }
  }

  // Simulates a dummy payment process and updates Firestore
  Future<void> processDummyPayment() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });

    try {
      // Simulate a payment delay
      await Future.delayed(const Duration(seconds: 3));

      // Save payment status to Firestore
      await savePaymentStatus();

      setState(() {
        isPaid = true;
      });

      // Redirect to homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print("Error during dummy payment: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner
      });
    }
  }

  // Function to save payment status to Firestore
  Future<void> savePaymentStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({'isPremium': true}, SetOptions(merge: true));
    } catch (e) {
      print("Error saving payment status: $e");
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
                  child: CircularProgressIndicator(), // Show loading spinner
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
                      // Free Version Card
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
                      // Premium Version Card
                      GestureDetector(
                        onTap: () async {
                          await processDummyPayment();
                        },
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
