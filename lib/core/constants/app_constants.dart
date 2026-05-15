/// App-wide constants for Waddek.lk
///
/// Secrets are injected at build time via `--dart-define-from-file=.env`
/// (preferred) or repeated `--dart-define=KEY=VALUE` flags. Do not put
/// real keys in this file — they end up in source control.
abstract class AppConstants {
  // ── Supabase ──────────────────────────────────────────────
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // ── Google Maps ───────────────────────────────────────────
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
