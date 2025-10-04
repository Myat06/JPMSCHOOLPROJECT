import 'package:flutter/material.dart';

class AppColors {
  // Palette
  static const Color primary = Color.fromARGB(255, 102, 126, 234); // Soft Purple
  static const Color secondary = Color.fromARGB(255, 118, 215, 196); // Mint Green
  static const Color accent = Color.fromARGB(255, 255, 159, 167); // Soft Coral
  static const Color background = Color.fromARGB(255, 247, 250, 252); // Light Blue-Gray
  static const Color textDark = Color.fromARGB(255, 45, 55, 72);
  static const Color textLight = Color.fromARGB(255, 255, 255, 255);

  // Semantic helpers
  static const Color success = Color(0xFF22C55E); // green 500
  static const Color warning = Color(0xFFF59E0B); // amber 500
  static const Color danger = Color(0xFFEF4444); // red 500
  static const Color muted = Color(0xFF94A3B8); // slate 400

  // Derived tints/shades
  static Color primaryLight = const Color.fromARGB(255, 102, 126, 234).withOpacity(0.12);
  static Color secondaryLight = const Color.fromARGB(255, 118, 215, 196).withOpacity(0.12);
  static Color accentLight = const Color.fromARGB(255, 255, 159, 167).withOpacity(0.12);
}


