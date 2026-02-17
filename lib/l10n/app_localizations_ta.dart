// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'வத்தெக்.lk';

  @override
  String get appTagline =>
      'உங்களுக்கு அருகிலுள்ள திறமையான தொழிலாளர்களைக் கண்டறியுங்கள்';

  @override
  String get welcome => 'வத்தெக் க்கு வரவேற்கிறோம்';

  @override
  String get enterPhone => 'தொடங்க உங்கள் தொலைபேசி எண்ணை உள்ளிடுங்கள்';

  @override
  String get phonePlaceholder => '77 123 4567';

  @override
  String get sendCode => 'சரிபார்ப்புக் குறியீட்டை அனுப்புங்கள்';

  @override
  String get verifyNumber => 'உங்கள் எண்ணைச் சரிபார்க்கவும்';

  @override
  String codeSentTo(String phone) {
    return 'குறியீடு $phone க்கு அனுப்பப்பட்டது';
  }

  @override
  String get verify => 'சரிபார்';

  @override
  String get resendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String resendIn(int seconds) {
    return '$seconds வினாடிகளில் மீண்டும் அனுப்பு';
  }

  @override
  String get invalidPhone =>
      'செல்லுபடியாகும் இலங்கை தொலைபேசி எண்ணை உள்ளிடுங்கள்';

  @override
  String get phoneRequired => 'தொலைபேசி எண் தேவை';

  @override
  String get enterVerificationCode => 'சரிபார்ப்புக் குறியீட்டை உள்ளிடுங்கள்';

  @override
  String get codeMustBe6Digits => 'குறியீடு 6 இலக்கங்களாக இருக்க வேண்டும்';

  @override
  String get otpSendFailed =>
      'OTP அனுப்புவதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get verificationFailed =>
      'சரிபார்ப்பு தோல்வியுற்றது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get iWantTo => 'நான் விரும்புகிறேன்…';

  @override
  String get chooseRole =>
      'வத்தெக்கை எவ்வாறு பயன்படுத்துவீர்கள் என்பதைத் தேர்ந்தெடுக்கவும்';

  @override
  String get findWorkers => 'திறமையான தொழிலாளர்களைக் கண்டறியுங்கள்';

  @override
  String get findWorkersDesc =>
      'வேலைகளை இடுகையிடுங்கள், மதிப்பீடுகளைப் பெறுங்கள், அருகிலுள்ள தொழிலாளர்களை நியமியுங்கள்';

  @override
  String get offerServices => 'என் சேவைகளை வழங்குங்கள்';

  @override
  String get offerServicesDesc =>
      'வேலை வாய்ப்புகளைப் பெறுங்கள், ஏலம் விடுங்கள், பணம் சம்பாதியுங்கள்';

  @override
  String get continueBtn => 'தொடரவும்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'සිංහල';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get languageChanged => 'மொழி மாற்றப்பட்டது';

  @override
  String get home => 'முகப்பு';

  @override
  String get jobs => 'வேலைகள்';

  @override
  String get wallet => 'பணப்பை';

  @override
  String get chat => 'அரட்டை';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get postJob => 'வேலையை இடுகையிடு';

  @override
  String get myJobs => 'எனது வேலைகள்';

  @override
  String get availableJobs => 'கிடைக்கும் வேலைகள்';

  @override
  String get jobDetails => 'வேலை விவரங்கள்';

  @override
  String get placeBid => 'ஏலம் விடு';

  @override
  String get acceptBid => 'ஏலத்தை ஏற்கவும்';

  @override
  String get unlockDetails => 'விவரங்களைத் திற';

  @override
  String get unlockFree => 'திற — இலவசம் (Pro Pass)';

  @override
  String unlockForAmount(String amount) {
    return 'திற — ரூ. $amount';
  }

  @override
  String get insufficientBalance => 'போதுமான இருப்பு இல்லை';

  @override
  String get topUpNow => 'இப்போது டாப் அப் செய்யுங்கள்';

  @override
  String get upgradeProPass => 'Pro Pass க்கு மேம்படுத்துங்கள்';

  @override
  String get walletBalance => 'பணப்பை இருப்பு';

  @override
  String get topUp => 'டாப் அப்';

  @override
  String get transactionHistory => 'பரிவர்த்தனை வரலாறு';

  @override
  String get proPass => 'வத்தெக் Pro Pass';

  @override
  String get proPassDesc =>
      'இலவச லீட் கட்டணங்கள், முன்னுரிமை தரவரிசை, சரிபார்க்கப்பட்ட பேட்ஜ்';

  @override
  String get proPassPrice => 'ரூ. 1,500/மாதம்';

  @override
  String get subscribe => 'சந்தா செலுத்துங்கள்';

  @override
  String get cancelSubscription => 'சந்தாவை ரத்து செய்யுங்கள்';

  @override
  String get reviews => 'மதிப்புரைகள்';

  @override
  String get submitReview => 'மதிப்புரையை சமர்ப்பிக்கவும்';

  @override
  String get rateExperience => 'உங்கள் அனுபவத்தை மதிப்பிடுங்கள்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get totalCredits => 'மொத்த கிரெடிட்கள்';

  @override
  String get bonus => 'போனஸ்';

  @override
  String get leadFee => 'லீட் கட்டணம்';

  @override
  String get refund => 'பணத்தைத் திருப்பி அளி';

  @override
  String get customer => 'வாடிக்கையாளர்';

  @override
  String get worker => 'தொழிலாளர்';

  @override
  String get markComplete => 'நிறைவு செய்யப்பட்டதாகக் குறிக்கவும்';

  @override
  String get reportIssue => 'சிக்கலைப் புகாரளிக்கவும்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get confirm => 'உறுதிப்படுத்து';

  @override
  String get save => 'சேமி';

  @override
  String get done => 'முடிந்தது';

  @override
  String get error => 'பிழை';

  @override
  String get success => 'வெற்றி';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get noResults => 'முடிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get cashPaymentNote =>
      'பணம் நேரடியாக தொழிலாளருக்கு ரொக்கமாக வழங்கப்படும்';

  @override
  String get tierWaddek => 'வத்தெக்';

  @override
  String get tierProfessional => 'தொழில்முறை';

  @override
  String get tierSupiri => 'சூப்பிரி';
}
