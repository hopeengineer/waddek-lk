// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Waddek.lk';

  @override
  String get appTagline => 'Find skilled workers near you';

  @override
  String get welcome => 'Welcome to Waddek';

  @override
  String get enterPhone => 'Enter your phone number to get started';

  @override
  String get phonePlaceholder => '77 123 4567';

  @override
  String get sendCode => 'Send Verification Code';

  @override
  String get verifyNumber => 'Verify your number';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get invalidPhone => 'Enter a valid Sri Lankan phone number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get enterVerificationCode => 'Enter the verification code';

  @override
  String get codeMustBe6Digits => 'Code must be 6 digits';

  @override
  String get otpSendFailed => 'Failed to send OTP. Please try again.';

  @override
  String get verificationFailed => 'Verification failed. Please try again.';

  @override
  String get iWantTo => 'I want to…';

  @override
  String get chooseRole => 'Choose how you\'ll use Waddek';

  @override
  String get findWorkers => 'Find skilled workers';

  @override
  String get findWorkersDesc => 'Post jobs, get quotes, hire nearby workers';

  @override
  String get offerServices => 'Offer my services';

  @override
  String get offerServicesDesc => 'Get job leads, place bids, earn money';

  @override
  String get continueBtn => 'Continue';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'සිංහල';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Jobs';

  @override
  String get wallet => 'Wallet';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get postJob => 'Post a Job';

  @override
  String get myJobs => 'My Jobs';

  @override
  String get availableJobs => 'Available Jobs';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get placeBid => 'Place Bid';

  @override
  String get acceptBid => 'Accept Bid';

  @override
  String get unlockDetails => 'Unlock Details';

  @override
  String get unlockFree => 'Unlock — Free (Pro Pass)';

  @override
  String unlockForAmount(String amount) {
    return 'Unlock — Rs. $amount';
  }

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get topUpNow => 'Top Up Now';

  @override
  String get upgradeProPass => 'Upgrade to Pro Pass';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get topUp => 'Top Up';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get proPass => 'Waddek Pro Pass';

  @override
  String get proPassDesc => 'Zero lead fees, priority ranking, verified badge';

  @override
  String get proPassPrice => 'Rs. 1,500/month';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get reviews => 'Reviews';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get rateExperience => 'Rate your experience';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get bonus => 'Bonus';

  @override
  String get leadFee => 'Lead Fee';

  @override
  String get refund => 'Refund';

  @override
  String get customer => 'Customer';

  @override
  String get worker => 'Worker';

  @override
  String get markComplete => 'Mark as Complete';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noResults => 'No results found';

  @override
  String get retry => 'Retry';

  @override
  String get cashPaymentNote =>
      'Payment is made in cash directly to the worker';

  @override
  String get tierWaddek => 'Waddek';

  @override
  String get tierProfessional => 'Professional';

  @override
  String get tierSupiri => 'Supiri';
}
