// lib/data/repositories/payment_repository.dart
import '../../core/services/razorpay_service.dart';

class PaymentRepository {
  // No longer needs an instance since RazorpayService methods are static
  PaymentRepository();

  void initializeRazorpay({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    RazorpayService.initialize(
      onSuccess: (dynamic response) {
        onSuccess({
          'paymentId': response.paymentId,
          'orderId': response.orderId,
          'signature': response.signature,
        });
      },
      onFailure: (dynamic response) {
        onFailure({
          'code': response.code,
          'message': response.message,
        });
      },
      onExternalWallet: (dynamic response) {
        onExternalWallet({
          'walletName': response.walletName ?? 'external_wallet',
        });
      },
    );
  }

  Future<void> openCheckout({
    required double amount,
    required String orderId,
    required String name,
    required String phone,
    required String email,
    String description = 'Payment for Just1Shop order',
  }) async {
    RazorpayService.openCheckout(
      amount: amount,
      orderId: orderId,
      name: name,
      phone: phone,
      email: email,
      description: description,
    );
  }

  void dispose() {
    RazorpayService.dispose();
  }
}
