import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application text styles
class AppTextStyles {
  // Display styles (large headings)
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  
  static const displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  // Heading styles
  static const headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  // Body styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  // Label styles (buttons, chips)
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  // Caption style (small secondary text)
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
