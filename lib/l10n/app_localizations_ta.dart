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
  String get subscribe => 'சந்தா செலுத்து';

  @override
  String get cancelSubscription => 'சந்தாவை ரத்து செய்';

  @override
  String get reviews => 'மதிப்புரைகள்';

  @override
  String get submitReview => 'மதிப்புரை எழுதுங்கள்';

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

  @override
  String get messages => 'செய்திகள்';

  @override
  String get alerts => 'எச்சரிக்கைகள்';

  @override
  String get myBids => 'எனது ஏலங்கள்';

  @override
  String get language => 'மொழி';

  @override
  String get account => 'கணக்கு';

  @override
  String get about => 'எங்களைப் பற்றி';

  @override
  String get version => 'பதிப்பு';

  @override
  String get logOutTitle => 'வெளியேற வேண்டுமா?';

  @override
  String get logOutMessage =>
      'மீண்டும் இதைப் பயன்படுத்த நீங்கள் மறுபடியும் உள்நுழைய வேண்டும்.';

  @override
  String get logOut => 'வெளியேறு';

  @override
  String get myProfile => 'எனது சுயவிவரம்';

  @override
  String get quickActions => 'விரைவு செயல்கள்';

  @override
  String get editProfile => 'சுயவிவரத்தை மாற்று';

  @override
  String get portfolio => 'எனது படைப்புகள்';

  @override
  String get mySkills => 'எனது திறமைகள்';

  @override
  String get updateLocation => 'இடத்தை மாற்று';

  @override
  String get switchToCustomerMode => 'வாடிக்கையாளராக மாறு';

  @override
  String get rating => 'மதிப்பீடு';

  @override
  String get status => 'நிலை';

  @override
  String get online => 'செயலில்';

  @override
  String get offline => 'செயலில் இல்லை';

  @override
  String get morningGreeting => 'காலை வணக்கம்,';

  @override
  String get afternoonGreeting => 'மதிய வணக்கம்,';

  @override
  String get eveningGreeting => 'மாலை வணக்கம்,';

  @override
  String get fallbackName => 'நீங்கள்';

  @override
  String get noProfileFound => 'சுயவிவரம் கிடைக்கவில்லை';

  @override
  String get becomeAWorker => 'ஒரு வத்தெக்கராக மாறுங்கள்';

  @override
  String get becomeAWorkerDesc =>
      'உங்கள் திறமைகளை வழங்கி வத்தெக்-ல் சம்பாதியுங்கள்';

  @override
  String get verifiedLabel => 'சரிபார்க்கப்பட்டது';

  @override
  String get verifyIdentity => 'உங்கள் அடையாளத்தை சரிபார்க்கவும்';

  @override
  String get welcomeBack => 'மீண்டும் வரவேற்கிறோம்';

  @override
  String get loginSubtitle =>
      'உங்கள் தொலைபேசி எண் அல்லது மின்னஞ்சல் வழியாக உள்நுழையவும்';

  @override
  String get phoneOrEmailHint => 'தொலைபேசி எண் அல்லது மின்னஞ்சல்';

  @override
  String get phoneOrEmailRequired =>
      'உங்கள் தொலைபேசி எண் அல்லது மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get passwordRequired => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get logIn => 'உள்நுழை';

  @override
  String get noAccount => 'கணக்கு இல்லையா? ';

  @override
  String get signUp => 'பதிவு செய்';

  @override
  String get workerActivationDesc =>
      'வத்தெக்-ல் சேவைகளை வழங்க, NIC பதிவேற்றம் மற்றும் திறமை தேர்வு உள்ளிட்ட சரிபார்ப்பை முடிக்க வேண்டும்.';

  @override
  String get startVerification => 'சரிபார்ப்பைத் தொடங்கு';

  @override
  String get notNow => 'இப்போது இல்லை';

  @override
  String get phoneUpdated => 'தொலைபேசி எண் புதுப்பிக்கப்பட்டது.';

  @override
  String get agreeToTermsRequired => 'சேவை விதிமுறைகளை ஒப்புக்கொள்ளவும்';

  @override
  String get createAccount => 'உங்கள் கணக்கை உருவாக்குங்கள்';

  @override
  String phoneVerified(String phone) {
    return 'தொலைபேசி எண் சரிபார்க்கப்பட்டது: $phone';
  }

  @override
  String get completeProfile => 'தொடங்க உங்கள் சுயவிவரத்தை நிறைவு செய்யுங்கள்';

  @override
  String get fullLegalName => 'முழுப் பெயர்';

  @override
  String get fullNameRequired => 'உங்கள் முழுப் பெயரை உள்ளிடவும்';

  @override
  String get firstAndLastNameRequired =>
      'முதல் பெயர் மற்றும் கடைசி பெயரை உள்ளிடவும்';

  @override
  String get fullNameHint => 'எ.கா. கமல் பெரேரா';

  @override
  String get emailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordMinLength =>
      'கடவுச்சொல் குறைந்தது 8 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get passwordHint => 'குறைந்தது 8 எழுத்துகள்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get passwordsDontMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get reEnterPassword => 'கடவுச்சொல்லை மீண்டும் உள்ளிடவும்';

  @override
  String get termsConsent =>
      'சேவை விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறேன்';

  @override
  String get createAccountCta => 'கணக்கை உருவாக்கு';

  @override
  String get pwWeak => 'பலவீனம்';

  @override
  String get pwFair => 'சராசரி';

  @override
  String get pwGood => 'நல்லது';

  @override
  String get pwStrong => 'வலுவானது';

  @override
  String get resetPasswordTitle => 'உங்கள் கடவுச்சொல்லை மீட்டமை';

  @override
  String get resetPasswordDesc =>
      'உங்கள் கணக்கின் தொலைபேசி எண்ணை உள்ளிடவும். புதிய கடவுச்சொல் அமைக்க ஒரு குறியீட்டை அனுப்புவோம்.';

  @override
  String get phoneHint => 'எ.கா. 0771234567';

  @override
  String get sendResetCode => 'மீட்டமைப்புக் குறியீட்டை அனுப்பு';

  @override
  String get setNewPasswordTitle => 'புதிய கடவுச்சொல் அமை';

  @override
  String get newPasswordDesc =>
      'குறைந்தது 8 எழுத்துகள் கொண்ட கடவுச்சொல்லைத் தேர்வுசெய்யவும்.';

  @override
  String get enterPasswordValidator => 'ஒரு கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get useAtLeast8Chars => 'குறைந்தது 8 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get newPasswordHint => 'புதிய கடவுச்சொல்';

  @override
  String get confirmNewPasswordHint => 'புதிய கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get updatePassword => 'கடவுச்சொல்லைப் புதுப்பி';

  @override
  String get passwordUpdatedMsg =>
      'கடவுச்சொல் புதுப்பிக்கப்பட்டது. நீங்கள் இப்போது உள்நுழைந்துள்ளீர்கள்.';

  @override
  String get category => 'வகை';

  @override
  String get jobTitle => 'வேலை தலைப்பு';

  @override
  String get jobTitleHint => 'எ.கா. சமையலறை குழாய் சரிசெய்தல்';

  @override
  String get descriptionOptional => 'விளக்கம் (விரும்பினால்)';

  @override
  String get descriptionHint => 'வேலையை விரிவாக விளக்குங்கள்...';

  @override
  String get minBudget => 'குறைந்தபட்ச பட்ஜெட் (ரூ.)';

  @override
  String get maxBudget => 'அதிகபட்ச பட்ஜெட் (ரூ.)';

  @override
  String get address => 'முகவரி';

  @override
  String get addressHint => 'வேலை எங்கே?';

  @override
  String get useCurrentLocation => 'தற்போதைய இடத்தைப் பயன்படுத்து';

  @override
  String get addPhotosOptional => 'புகைப்படங்களைச் சேர்க்கவும் (விரும்பினால்)';

  @override
  String photosAttached(int count) {
    return '$count புகைப்படம்(ங்கள்) சேர்க்கப்பட்டுள்ளன';
  }

  @override
  String get selectCategory => 'ஒரு வகையைத் தேர்வுசெய்யவும்';

  @override
  String get enterTitle => 'ஒரு தலைப்பை உள்ளிடவும்';

  @override
  String get profileNotLoaded => 'சுயவிவரம் ஏற்றப்படவில்லை';

  @override
  String get jobPosted => 'வேலை இடுகையிடப்பட்டது.';

  @override
  String get locationPermissionDenied => 'இருப்பிட அனுமதி மறுக்கப்பட்டது';

  @override
  String get locationSet => 'இடம் அமைக்கப்பட்டது.';

  @override
  String get verifyToPostJob =>
      'வேலை இடுகையிட உங்கள் அடையாளத்தை சரிபார்க்கவும்';

  @override
  String get recoverAccount => 'கணக்கை மீட்டெடு';

  @override
  String get noJobsYet => 'இன்னும் வேலைகள் இல்லை';

  @override
  String get postFirstJob =>
      'தொழிலாளர்களைக் கண்டுபிடிக்க உங்கள் முதல் வேலையை இடுகையிடுங்கள்';

  @override
  String get noAvailableJobs => 'இப்போது கிடைக்கும் வேலைகள் இல்லை';

  @override
  String get noJobsNotifyDesc =>
      'உங்கள் திறமைகளுக்கு பொருந்தும் புதிய வேலைகள் வந்தால் தெரிவிப்போம்';

  @override
  String get unknown => 'தெரியாது';

  @override
  String get bidsLoadError => 'ஏலங்களை ஏற்றுவதில் பிழை';

  @override
  String get noBidsYet => 'இன்னும் ஏலங்கள் இல்லை';

  @override
  String get noBidsDesc =>
      'கிடைக்கும் வேலைகளை பார்வையிட்டு ஏலம் விட்டு சம்பாதியுங்கள்.';

  @override
  String get browseJobs => 'வேலைகளை பார்';

  @override
  String get total => 'மொத்தம்';

  @override
  String get pending => 'நிலுவையில்';

  @override
  String get won => 'வென்றது';

  @override
  String get accepted => 'ஏற்கப்பட்டது';

  @override
  String get rejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get locked => 'பூட்டப்பட்டது';

  @override
  String get jobNotFound => 'வேலை கண்டுபிடிக்கப்படவில்லை';

  @override
  String get description => 'விளக்கம்';

  @override
  String get bids => 'ஏலங்கள்';

  @override
  String get workersWillBid =>
      'நீங்கள் வேலையை வெளியிட்டவுடன் தொழிலாளர்கள் ஏலம் விடுவார்கள்';

  @override
  String get decline => 'நிராகரி';

  @override
  String get declineBidConfirm => 'ஏலத்தை நிராகரிக்கவா?';

  @override
  String get acceptBidShort => 'ஏற்று';

  @override
  String get budget => 'பட்ஜெட்';

  @override
  String get scheduled => 'திட்டமிடப்பட்டது';

  @override
  String get broadcastToWorkers => 'தொழிலாளர்களுக்கு அனுப்பு';

  @override
  String byCustomer(String name) {
    return '$name வழங்கியது';
  }

  @override
  String get walletTitle => 'வத்தெக் பணப்பை';

  @override
  String get availableBalance => 'கிடைக்கும் இருப்பு';

  @override
  String get unlocksUsed => 'பயன்படுத்திய திறப்புகள்';

  @override
  String get daysLeft => 'மீதமுள்ள நாட்கள்';

  @override
  String get active => 'செயலில்';

  @override
  String get cancelling => 'ரத்து செய்கிறது';

  @override
  String get benefitsActiveUntil =>
      'காலம் முடியும் வரை சலுகைகள் செயலில் உள்ளன.';

  @override
  String get upgradeToProPass => 'Pro Pass-க்கு மேம்படுத்து';

  @override
  String get proPassUpsellDesc =>
      'இலவச லீட் கட்டணம் • முன்னுரிமை தரவரிசை • சரிபார்க்கப்பட்ட பேட்ஜ்\nமாதம் ரூ. 1,500 மட்டுமே';

  @override
  String get learnMore => 'மேலும் அறிய';

  @override
  String get noConversations => 'இன்னும் உரையாடல்கள் இல்லை';

  @override
  String get chatWillAppear =>
      'நீங்கள் வேலையுடன் இணைந்தவுடன் அரட்டை இங்கே காண்பிக்கப்படும்';

  @override
  String get noNotificationsYet => 'இன்னும் அறிவிப்புகள் இல்லை';

  @override
  String get wellNotifyYou => 'ஏதாவது நடந்தால் உங்களுக்குத் தெரிவிப்போம்';

  @override
  String get markAllRead => 'எல்லாவற்றையும் படித்ததாக குறி';

  @override
  String get searchHint => 'தொழிலாளர்கள், சேவைகள் தேடுங்கள்...';

  @override
  String get popularServices => 'பிரபலமான சேவைகள்';

  @override
  String get proPassTagline => 'உங்கள் வணிகத்தை வளர்க்க சிறந்த வழி';

  @override
  String proPassPriceMonthly(String price) {
    return 'மாதம் ரூ. $price';
  }

  @override
  String get zeroLeadFees => 'லீட் கட்டணம் இல்லை';

  @override
  String get zeroLeadFeesDesc =>
      'வாடிக்கையாளர் விவரங்களை இலவசமாகத் திற — மாதம் 50 வரை.';

  @override
  String get priorityRanking => 'முன்னுரிமை தரவரிசை';

  @override
  String get priorityRankingDesc =>
      'உங்கள் ஏலங்கள் முதலில் தோன்றும். PAYG தொழிலாளர்களுக்கு முன் அறிவிக்கப்படும்.';

  @override
  String get verifiedBadgeBenefit => 'சரிபார்க்கப்பட்ட பேட்ஜ்';

  @override
  String get verifiedBadgeBenefitDesc =>
      'உங்கள் சுயவிவரம் மற்றும் ஏலங்களில் Pro பேட்ஜுடன் தனித்து தெரியுங்கள்.';

  @override
  String get saveMoney => 'பணம் சேமி';

  @override
  String get saveMoneyDesc =>
      'மாதம் 20+ வேலைகள் செய்கிறீர்களா? Pro Pass லீட் கட்டணத்தை விட மலிவானது.';

  @override
  String get breakEvenTitle => 'சம நிலை கணக்கீடு';

  @override
  String get breakEvenDesc =>
      'லீட் ஒன்றுக்கு ரூ. 75 என்றால், 20 திறப்புகளுக்குப் பிறகே Pro Pass-ன் கட்டணம் திரும்புகிறது. மீதி 30-ம் இலவசம்!';

  @override
  String get verifyToSubscribe =>
      'சந்தாதாரராக ஆக உங்கள் அடையாளத்தை சரிபார்க்கவும்';

  @override
  String get proPassOnlyForVerified =>
      'Pro Pass சரிபார்க்கப்பட்ட பயனர்களுக்கு மட்டுமே. ஒரு நிமிடம் ஆகும்.';

  @override
  String get subscribeToProPass => 'Pro Pass-க்கு சந்தா செலுத்து';

  @override
  String get cancelAnytime =>
      'எப்போது வேண்டுமானாலும் ரத்து செய்யலாம். கட்டாயமில்லை.';

  @override
  String get payHereInitiated => 'PayHere சந்தா செலுத்துதல் தொடங்கப்பட்டது';

  @override
  String get searchFailed => 'தேடல் தோல்வியடைந்தது';

  @override
  String get noWorkersFound => 'தொழிலாளர்கள் கிடைக்கவில்லை';

  @override
  String get tryDifferentSearch => 'வேறு தேடல் வார்த்தையை முயற்சிக்கவும்';

  @override
  String get identityVerification => 'அடையாள சரிபார்ப்பு';

  @override
  String get pickDocument => 'நீங்கள் பயன்படுத்தும் ஆவணத்தைத் தேர்வுசெய்யவும்';

  @override
  String get startVerificationBtn => 'சரிபார்ப்பைத் தொடங்கு';

  @override
  String get waitingForVerification => 'சரிபார்ப்புக்காகக் காத்திருக்கிறது…';

  @override
  String attemptsUsed(int used, int total) {
    return 'பயன்படுத்திய முயற்சிகள்: $total-ல் $used';
  }

  @override
  String get postJobShort => 'வேலை இடு';

  @override
  String get proPassShort => 'Pro Pass';

  @override
  String get nearestWorkers => 'அருகிலுள்ள தொழிலாளர்கள்';

  @override
  String get onlineOnly => 'செயலில் உள்ளவர்கள் மட்டும்';

  @override
  String get all => 'அனைத்தும்';

  @override
  String get findServiceOrWorker => 'சேவை அல்லது தொழிலாளரை தேடுங்கள்...';

  @override
  String jobsCountLabel(int count) {
    return '$count வேலைகள்';
  }

  @override
  String get noWorkersMatch =>
      'இந்த வடிகட்டிக்கு பொருந்தும் தொழிலாளர்கள் இல்லை';

  @override
  String get tryDifferentCategory =>
      'வேறு வகையை முயற்சிக்கவும் அல்லது \"செயலில் உள்ளவர்கள் மட்டும்\" ஆஃப் செய்யவும்.';

  @override
  String get enableLocation =>
      'அருகிலுள்ள தொழிலாளர்களைப் பார்க்க இருப்பிடத்தை இயக்கவும்';

  @override
  String get enableLocationDesc =>
      'வத்தெக் உங்கள் பகுதியில் தொழிலாளர்களை தூரத்தின் அடிப்படையில் காட்டுகிறது. இருப்பிடம் இல்லாமல் எங்களால் வரிசைப்படுத்த முடியாது.';

  @override
  String get tryAgain => 'மீண்டும் முயற்சி செய்';
}
