import 'package:flutter/material.dart';

/// Pick the localized name from a category row (or any map with the
/// `name_en` / `name_si` / `name_ta` columns) based on the current
/// locale. Falls back to `name_en` if the localized column is missing
/// or empty.
///
/// The categories table on Supabase has parallel columns per language;
/// `name_en` is required, `name_si` / `name_ta` are nullable.
String localizedCategoryName(Map<String, dynamic> cat, Locale locale) {
  final code = locale.languageCode;
  final localized = code == 'si'
      ? cat['name_si'] as String?
      : code == 'ta'
          ? cat['name_ta'] as String?
          : null;
  if (localized != null && localized.isNotEmpty) return localized;
  return cat['name_en'] as String? ?? '?';
}
