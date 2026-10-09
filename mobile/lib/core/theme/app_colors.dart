import 'package:flutter/material.dart';

/// Application color constants for Light and Dark themes
class AppColors {
  // Light Theme Colors
  static const lightBackground = Color(0xFFF5F5F5); // Cream/off-white
  static const lightSurface = Color(0xFFFFFFFF); // White cards
  static const lightPrimary = Color(0xFF00BCD4); // Cyan
  static const lightPrimaryVariant = Color(0xFF0097A7);
  static const lightTextPrimary = Color(0xFF1A1A1A); // Dark gray
  static const lightTextSecondary = Color(0xFF7A7A7A); // Medium gray
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightError = Color(0xFFE53935);
  static const lightSuccess = Color(0xFF43A047);
  
  // Dark Theme Colors
  static const darkBackground = Color(0xFF1A2530); // Deep teal
  static const darkSurface = Color(0xFF243442); // Lighter teal cards
  static const darkPrimary = Color(0xFF00BCD4); // Cyan (same as light)
  static const darkPrimaryVariant = Color(0xFF00ACC1);
  static const darkTextPrimary = Color(0xFFFFFFFF); // White
  static const darkTextSecondary = Color(0xFFB0B0B0); // Light gray
  static const darkBorder = Color(0xFF3A4856);
  static const darkError = Color(0xFFEF5350);
  static const darkSuccess = Color(0xFF66BB6A);
  
  // Gradient Colors (for welcome/auth screens)
  static const gradientStart = Color(0xFF1A2530);
  static const gradientEnd = Color(0xFF0D1419);
  
  // Common Colors (same in both themes)
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Colors.transparent;
}
