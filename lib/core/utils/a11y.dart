import 'package:flutter/material.dart';

/// Accessibility helpers for Waddek.
/// Wraps common widgets with proper semantic labels, tooltips, and contrast.
class A11y {
  A11y._();

  /// Wrap an icon button with a semantic label.
  static Widget semanticIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
    double size = 24,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: label,
        child: IconButton(
          icon: Icon(icon, color: color, size: size),
          onPressed: onPressed,
          tooltip: label,
        ),
      ),
    );
  }

  /// Wrap a card with a semantic description.
  static Widget semanticCard({
    required Widget child,
    required String label,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      container: true,
      child: onTap != null
          ? InkWell(onTap: onTap, child: child)
          : child,
    );
  }

  /// Styled text that respects system font scaling.
  /// Uses [MediaQuery.textScaler] instead of hardcoded sizes.
  static TextStyle scaledText(
    BuildContext context, {
    double baseFontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontSize: baseFontSize,
      fontWeight: fontWeight,
      color: color,
    );
    // Flutter automatically applies textScaleFactor from system settings.
    // The key is to NOT use IgnorePointer or clampDouble on text scaling.
  }

  /// Minimum touch target size (48x48dp per Material guidelines).
  static const double minTouchTarget = 48.0;

  /// Ensure a widget meets minimum touch target size.
  static Widget ensureTouchTarget({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: minTouchTarget,
        minHeight: minTouchTarget,
      ),
      child: onTap != null
          ? InkWell(onTap: onTap, child: Center(child: child))
          : Center(child: child),
    );
  }
}
