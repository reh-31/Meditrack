import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MediTrack Color Palette
/// A professional medical-themed palette built around deep blues and teals.
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary blues
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Accent teal
  static const Color accent = Color(0xFF00ACC1);
  static const Color accentLight = Color(0xFF00BCD4);

  // Backgrounds
  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textHint = Color(0xFF90A4AE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF039BE5);

  // Medicine type colours
  static const Color tablet = Color(0xFF5C6BC0);
  static const Color capsule = Color(0xFF26A69A);
  static const Color syrup = Color(0xFFEF5350);
  static const Color injection = Color(0xFF8D6E63);
  static const Color drops = Color(0xFF29B6F6);
  static const Color cream = Color(0xFFFFA726);
  static const Color other = Color(0xFF78909C);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
