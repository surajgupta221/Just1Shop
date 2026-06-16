// lib/core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Just1Shop';
  static const String appVersion = '1.0.0';
  static const String productionDomain = 'https://www.just1shop.com';

  // API URLs
  static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  static const String webBaseUrl = productionDomain;
  // static const String baseUrl = 'http://localhost:8000'; // For iOS simulator

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String bannersCollection = 'banners';
  static const String couponsCollection = 'coupons';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleDelivery = 'delivery';
  static const String ownerPhone = '8987767301';

  // Order Status
  static const String orderPlaced = 'placed';
  static const String orderPacked = 'packed';
  static const String orderOutForDelivery = 'out_for_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';

  // Payment Methods
  static const String paymentOnline = 'online';
  static const String paymentCOD = 'cod';

  // Delivery Charges
  static const double deliveryCharge = 40.0;
  static const double freeDeliveryThreshold = 500.0;

  // App Colors
  static const int primaryColor = 0xFF4CAF50;
  static const int secondaryColor = 0xFF81C784;
  static const int accentColor = 0xFFFF9800;

  // Delivery Time
  static const String deliveryTime = 'Under 24 hours';

  static String normalizeIndianMobile(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    return digits;
  }

  static bool isOwnerPhone(String phone) {
    return normalizeIndianMobile(phone) == ownerPhone;
  }
}
