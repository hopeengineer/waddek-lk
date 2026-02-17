import 'package:intl/intl.dart';

/// General utility helpers for Waddek.lk.
abstract class Helpers {
  // ── Currency Formatting ─────────────────────────────────
  static final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  /// Format a number as Sri Lankan Rupees: "Rs. 1,500.00"
  static String formatLKR(double amount) {
    return 'Rs. ${_currencyFormat.format(amount)}';
  }

  /// Format a number as credits: "Rs. 525"
  static String formatCredits(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  // ── Distance ────────────────────────────────────────────
  /// Format distance in meters to a readable string.
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()}m';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  // ── Time ────────────────────────────────────────────────
  static final _timeFormat = DateFormat('h:mm a');
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');

  /// "2:30 PM"
  static String formatTime(DateTime dt) => _timeFormat.format(dt.toLocal());

  /// "Feb 17, 2026"
  static String formatDate(DateTime dt) => _dateFormat.format(dt.toLocal());

  /// "Feb 17, 2026 2:30 PM"
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt.toLocal());

  /// "2 hours ago", "just now", "3 days ago"
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  // ── Strings ─────────────────────────────────────────────
  /// Mask phone number: "+94771234567" → "+94 ** *** 4567"
  static String maskPhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 3)} ** *** ${phone.substring(phone.length - 4)}';
  }

  /// Truncate text with ellipsis.
  static String truncate(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  /// Capitalize first letter.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  // ── Rating ──────────────────────────────────────────────
  /// Format rating: 4.80 → "4.8", 5.00 → "5.0"
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}
