// lib/core/utils/helpers.dart
import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String getOrderStatusText(String status) {
    switch (status) {
      case 'placed':
        return 'Order Placed';
      case 'packed':
        return 'Order Packed';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static String getPaymentStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Payment Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Payment Failed';
      default:
        return 'Unknown';
    }
  }

  static String getPaymentMethodText(String method) {
    switch (method) {
      case 'online':
        return 'Online Payment';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return 'Unknown';
    }
  }

  static double calculateDiscount(double originalPrice, double? discountPrice) {
    if (discountPrice == null || discountPrice >= originalPrice) {
      return 0.0;
    }
    return originalPrice - discountPrice;
  }

  static double calculateDiscountPercentage(
      double originalPrice, double? discountPrice) {
    if (discountPrice == null || discountPrice >= originalPrice) {
      return 0.0;
    }
    return ((originalPrice - discountPrice) / originalPrice) * 100;
  }

  static String formatWeight(String unit) {
    // Convert units to more readable format
    switch (unit.toLowerCase()) {
      case 'kg':
        return 'Kg';
      case 'g':
        return 'g';
      case 'l':
        return 'L';
      case 'ml':
        return 'ml';
      case 'pcs':
        return 'pcs';
      case 'pack':
        return 'Pack';
      default:
        return unit;
    }
  }

  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  static String getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }
}
