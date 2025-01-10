import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  final String userId;
  Timer? _timer;

  SubscriptionService({required this.userId});

  /// Start subscription status checking
  void startSubscriptionCheck(Duration interval, Function(bool) onStatusUpdate) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(interval, (_) async {
      final isPremium = await getCurrentPremiumStatus();
      onStatusUpdate(isPremium);
    });
  }

  /// Stop subscription status checking
  void stopSubscriptionCheck() {
    _timer?.cancel();
  }

  /// Fetch the current subscription status
  Future<bool> getCurrentPremiumStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()?['isPremium'] ?? false;
      }
    } catch (e) {
      print('Error fetching subscription status: $e');
    }
    return false; // Default to non-premium on error
  }
}
