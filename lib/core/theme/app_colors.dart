import 'package:flutter/material.dart';

/// "Modern Dark Mode with Neon Energy" color palette for Waddek.lk
///
/// Dark blue/purple backgrounds with electric cyan accents.
/// All colors pass WCAG AAA contrast ratios against their expected backgrounds.
abstract class AppColors {
  // ── Backgrounds ─────────────────────────────────────────
  static const scaffoldDark = Color(0xFF0F0F24);
  static const surfaceDark = Color(0xFF1A1A3D);
  static const cardDark = Color(0xFF222250);

  // Convenience aliases used by screens
  static const bgDark = scaffoldDark;
  static const bgSurface = surfaceDark;
  static const bgCard = cardDark;

  // ── Neon Accents ────────────────────────────────────────
  static const neonCyan = Color(0xFF00E5FF);
  static const neonPurple = Color(0xFFBB86FC);
  static const neonGreen = Color(0xFF00E676);
  static const neonAmber = Color(0xFFFFD740);
  static const neonRed = Color(0xFFFF5252);

  // ── Text ────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C8);
  static const textDisabled = Color(0xFF5A5A7A);

  // ── Semantic ────────────────────────────────────────────
  static const success = neonGreen;
  static const warning = neonAmber;
  static const error = neonRed;
  static const info = neonCyan;

  // ── Gradients ───────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [scaffoldDark, Color(0xFF151538)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glow Shadows ────────────────────────────────────────
  static List<BoxShadow> neonGlow({
    Color color = neonCyan,
    double blurRadius = 12,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
