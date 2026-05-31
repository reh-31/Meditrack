import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MediTrack Color Palette
/// A professional medical-themed palette built around deep blues and teals.
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary Indigo
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);

  // Accent Teal
  static const Color accent = Color(0xFF0D9488);
  static const Color accentLight = Color(0xFF14B8A6);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Medicine type colours
  static const Color tablet = Color(0xFF6366F1);
  static const Color capsule = Color(0xFF14B8A6);
  static const Color syrup = Color(0xFFF43F5E);
  static const Color injection = Color(0xFF8B5CF6);
  static const Color drops = Color(0xFF0EA5E9);
  static const Color cream = Color(0xFFF59E0B);
  static const Color other = Color(0xFF64748B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
