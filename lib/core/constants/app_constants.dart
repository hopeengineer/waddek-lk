/// App-wide constants for Waddek.lk
abstract class AppConstants {
  // ── Supabase ──────────────────────────────────────────────
  static const supabaseUrl = 'https://dkmjmqkingddvtntpysy.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrbWptcWtpbmdkZHZ0bnRweXN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMDk5OTEsImV4cCI6MjA4Njg4NTk5MX0.DXJJRbXOphW-D4hYBTLq_WXdfs9NxGlmrKuk4Ncurtc';

  // ── Google Maps ───────────────────────────────────────────
  // Passed at build time: flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  // ── Broadcast ─────────────────────────────────────────────
  static const defaultBroadcastRadiusKm = 5;
  static const maxBroadcastRadiusKm = 25;
  static const maxWorkersNotified = 3;

  // ── OTP ───────────────────────────────────────────────────
  static const otpLength = 6;
  static const otpExpiryMinutes = 5;
  static const maxOtpAttemptsPerHour = 3;

  // ── Wallet ────────────────────────────────────────────────
  static const leadFeeLKR = 75.0;
  static const proPassMonthlyLKR = 1500.0;
  static const proPassUnlockCap = 50;

  // ── Tier Thresholds ───────────────────────────────────────
  static const professionalMinJobs = 20;
  static const professionalMinRating = 4.0;
  static const supiriMinJobs = 50;
  static const supiriMinRating = 4.8;

  // ── Location ──────────────────────────────────────────────
  static const locationDistanceFilterMeters = 500;

  // ── Timeouts ──────────────────────────────────────────────
  static const broadcastRetryDelayMinutes = 30;
  static const jobAutoTimeoutHours = 24;
}
