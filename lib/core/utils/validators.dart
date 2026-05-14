// lib/core/utils/validators.dart
class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    String phone = value.replaceAll(RegExp(r'\D'), '');

    if (phone.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!phone.startsWith('6') &&
        !phone.startsWith('7') &&
        !phone.startsWith('8') &&
        !phone.startsWith('9')) {
      return 'Phone number must start with 6, 7, 8, or 9';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please provide a complete address';
    }

    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    if (value.length != 6) {
      return 'Pincode must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must contain only digits';
    }

    return null;
  }

  static String? validateLandmark(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Landmark is optional
    }

    if (value.length > 100) {
      return 'Landmark must be less than 100 characters';
    }

    return null;
  }
}
