/// Validation helpers for common Waddek.lk input fields.
abstract class Validators {
  /// Validate Sri Lankan phone number (+94 followed by 9 digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and dashes
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Accept formats: 0771234567, +94771234567, 94771234567
    final regex = RegExp(r'^(\+?94|0)?[0-9]{9}$');
    if (!regex.hasMatch(clean)) {
      return 'Enter a valid Sri Lankan phone number';
    }
    return null;
  }

  /// Normalize phone to +94 format
  static String normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.startsWith('+94')) return clean;
    if (clean.startsWith('94')) return '+$clean';
    if (clean.startsWith('0')) return '+94${clean.substring(1)}';
    return '+94$clean';
  }

  /// Validate Sri Lankan NIC number (old 9-digit+V/X or new 12-digit).
  static String? nic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIC number is required';
    }
    final clean = value.trim();
    // Old format: 9 digits + V or X
    final oldFormat = RegExp(r'^[0-9]{9}[VvXx]$');
    // New format: 12 digits
    final newFormat = RegExp(r'^[0-9]{12}$');

    if (!oldFormat.hasMatch(clean) && !newFormat.hasMatch(clean)) {
      return 'Enter a valid NIC number';
    }
    return null;
  }

  /// Validate email (optional field).
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate OTP code (6 digits).
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the verification code';
    }
    if (value.trim().length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Code must be 6 digits';
    }
    return null;
  }

  /// Validate required text field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate budget range (min <= max, both positive).
  static String? budgetRange(double? min, double? max) {
    if (min != null && max != null && min > max) {
      return 'Min budget cannot exceed max budget';
    }
    if (min != null && min < 0) return 'Budget cannot be negative';
    if (max != null && max < 0) return 'Budget cannot be negative';
    return null;
  }
}
