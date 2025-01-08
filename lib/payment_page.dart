import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  final String userId;

  const PaymentPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;

  // Replace with your backend URL for creating PaymentIntent
  static const String backendUrl =
      'https://us-central1-fitopia-42331.cloudfunctions.net/api';

  Future<void> processPayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Fetch PaymentIntent details from the backend
      final paymentIntent = await _createPaymentIntent();

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['clientSecret'],
          merchantDisplayName: 'Fitopia Premium',
        ),
      );

      // 3. Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // 4. Payment succeeded
      await _onPaymentSuccess();
    } catch (e) {
      _onPaymentError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': 50000, // Rp. 50,000 in the smallest currency unit
          'currency': 'idr', // Indonesian Rupiah
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to create PaymentIntent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating PaymentIntent: $e');
    }
  }

  Future<void> _onPaymentSuccess() async {
    // Save the payment status to Firestore
    await savePaymentStatus();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Payment completed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onPaymentError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> savePaymentStatus() async {
    // Save the user's premium status in Firestore
    // Implement Firestore update logic here, e.g.:
    /*
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({'isPremium': true}, SetOptions(merge: true));
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upgrade to Premium",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: processPayment,
                    child: const Text("Pay with Stripe"),
                  ),
                ],
              ),
            ),
    );
  }
}
