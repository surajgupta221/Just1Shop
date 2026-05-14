// lib/core/constants/ui_constants.dart
import 'package:flutter/material.dart';

class UIConstants {
  // Colors - Zepto/Blinkit Style
  static const Color primaryColor = Color(0xFF10B981); // Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xD0F8E3);
  static const Color accentColor = Color(0xFFFF6B6B); // Red for offers
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color borderColor = Color(0xFFD1D5DB);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);

  // Spacing
  static const double paddingXXS = 4;
  static const double paddingXS = 8;
  static const double paddingS = 12;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;
  static const double paddingXXL = 40;

  // Border Radius
  static const double radiusS = 6;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 20;
  static const double radiusRound = 100;

  // Icon Sizes
  static const double iconXS = 16;
  static const double iconS = 20;
  static const double iconM = 24;
  static const double iconL = 32;
  static const double iconXL = 40;

  // Text Sizes
  static const double textXS = 12;
  static const double textS = 13;
  static const double textM = 14;
  static const double textL = 16;
  static const double textXL = 18;
  static const double textXXL = 20;
  static const double text2XL = 24;
  static const double text3XL = 28;

  // Shadow
  static const BoxShadow shadowS = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowM = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowL = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> shadowsM = [shadowM];
  static const List<BoxShadow> shadowsL = [shadowL];
}

// Text Styles
class UITextStyles {
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: UIConstants.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: UIConstants.textPrimary,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: UIConstants.textPrimary,
    height: 1.4,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: UIConstants.textPrimary,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: UIConstants.textPrimary,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: UIConstants.textPrimary,
    height: 1.5,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: UIConstants.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: UIConstants.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: UIConstants.textSecondary,
    height: 1.5,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: UIConstants.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: UIConstants.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: UIConstants.textSecondary,
    height: 1.4,
  );
}
