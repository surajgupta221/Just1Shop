// lib/data/models/payment_models.dart

class PaymentSuccessResponse {
  final String paymentId;
  final String orderId;
  final String signature;

  PaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  factory PaymentSuccessResponse.fromMap(Map<String, dynamic> map) {
    return PaymentSuccessResponse(
      paymentId: map['paymentId'] ?? '',
      orderId: map['orderId'] ?? '',
      signature: map['signature'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
    };
  }
}

class PaymentFailureResponse {
  final String code;
  final String message;

  PaymentFailureResponse({
    required this.code,
    required this.message,
  });

  factory PaymentFailureResponse.fromMap(Map<String, dynamic> map) {
    return PaymentFailureResponse(
      code: map['code'] ?? '',
      message: map['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }
}

class ExternalWalletResponse {
  final String walletName;

  ExternalWalletResponse({
    required this.walletName,
  });

  factory ExternalWalletResponse.fromMap(Map<String, dynamic> map) {
    return ExternalWalletResponse(
      walletName: map['walletName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletName': walletName,
    };
  }
}
