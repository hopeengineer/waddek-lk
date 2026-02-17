/// Supabase table, bucket, and channel name constants.
/// Single source of truth — avoids typos in string references.
abstract class SupabaseConstants {
  // ── Tables ────────────────────────────────────────────────
  static const profiles = 'profiles';
  static const categories = 'categories';
  static const workerCategories = 'worker_categories';
  static const portfolioImages = 'portfolio_images';
  static const jobs = 'jobs';
  static const bids = 'bids';
  static const wallets = 'wallets';
  static const transactions = 'transactions';
  static const topUpPackages = 'top_up_packages';
  static const subscriptionPlans = 'subscription_plans';
  static const subscriptions = 'subscriptions';
  static const reviews = 'reviews';
  static const notifications = 'notifications';
  static const conversations = 'conversations';
  static const messages = 'messages';
  static const disputes = 'disputes';
  static const otpCodes = 'otp_codes';

  // ── Storage Buckets ───────────────────────────────────────
  static const avatarsBucket = 'avatars';
  static const nicPhotosBucket = 'nic-photos';
  static const portfolioBucket = 'portfolio';
  static const jobPhotosBucket = 'job-photos';
  static const evidenceBucket = 'evidence';

  // ── Edge Functions ────────────────────────────────────────
  static const fnSendOtp = 'send-otp';
  static const fnVerifyOtp = 'verify-otp';
  static const fnBroadcastJob = 'broadcast-job';
  static const fnUnlockDetails = 'unlock-details';
  static const fnPayhereNotify = 'payhere-notify';
  static const fnPayhereReturn = 'payhere-return';
  static const fnManageSubscription = 'manage-subscription';
  static const fnTierReview = 'tier-review';
}
