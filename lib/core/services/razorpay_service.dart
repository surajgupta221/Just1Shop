// lib/core/services/razorpay_service.dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  static Razorpay? _razorpay;

  static void initialize({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  static void openCheckout({
    required double amount,
    required String orderId,
    required String name,
    required String phone,
    required String email,
    String description = 'Payment for Just1Shop order',
  }) {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY_ID', // Replace with your key
      'amount': (amount * 100).toInt(), // Amount in paise
      'order_id': orderId,
      'name': 'Just1Shop',
      'description': description,
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'theme': {'color': '#4CAF50'}
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  static void dispose() {
    _razorpay?.clear();
  }
}
