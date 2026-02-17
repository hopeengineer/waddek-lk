import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography system using Google Fonts Poppins.
abstract class AppTextStyles {
  static TextStyle _poppins({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ── Headings ────────────────────────────────────────────
  static TextStyle get h1 => _poppins(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get h2 => _poppins(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get h3 => _poppins(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get h4 => _poppins(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);

  // ── Body ────────────────────────────────────────────────
  static TextStyle get bodyLarge => _poppins(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => _poppins(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => _poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ── Labels ──────────────────────────────────────────────
  static TextStyle get labelLarge => _poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static TextStyle get labelMedium => _poppins(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static TextStyle get labelSmall => _poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ── Button ──────────────────────────────────────────────
  static TextStyle get button => _poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ── Special ─────────────────────────────────────────────
  static TextStyle get price => _poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.neonCyan,
  );

  static TextStyle get badge => _poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );
}
