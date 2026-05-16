// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'වැඩ්ඩෙක්.lk';

  @override
  String get appTagline => 'ඔබට ආසන්නයේ දක්ෂ කම්කරුවන් සොයන්න';

  @override
  String get welcome => 'වැඩ්ඩෙක් වෙත සාදරයෙන් පිළිගනිමු';

  @override
  String get enterPhone => 'ආරම්භ කිරීමට ඔබේ දුරකථන අංකය ඇතුළත් කරන්න';

  @override
  String get phonePlaceholder => '77 123 4567';

  @override
  String get sendCode => 'සත්‍යාපන කේතය යවන්න';

  @override
  String get verifyNumber => 'ඔබේ අංකය සත්‍යාපනය කරන්න';

  @override
  String codeSentTo(String phone) {
    return 'කේතය $phone වෙත යවන ලදී';
  }

  @override
  String get verify => 'සත්‍යාපනය';

  @override
  String get resendCode => 'කේතය නැවත යවන්න';

  @override
  String resendIn(int seconds) {
    return 'තත්පර $secondsකින් නැවත යවන්න';
  }

  @override
  String get invalidPhone => 'වලංගු ශ්‍රී ලාංකික දුරකථන අංකයක් ඇතුළත් කරන්න';

  @override
  String get phoneRequired => 'දුරකථන අංකය අවශ්‍යයි';

  @override
  String get enterVerificationCode => 'සත්‍යාපන කේතය ඇතුළත් කරන්න';

  @override
  String get codeMustBe6Digits => 'කේතය ඉලක්කම් 6ක් විය යුතුයි';

  @override
  String get otpSendFailed => 'OTP යැවීමට අසමත් විය. නැවත උත්සාහ කරන්න.';

  @override
  String get verificationFailed => 'සත්‍යාපනය අසාර්ථකයි. නැවත උත්සාහ කරන්න.';

  @override
  String get iWantTo => 'මට අවශ්‍යයි…';

  @override
  String get chooseRole => 'ඔබ වැඩ්ඩෙක් භාවිතා කරන ආකාරය තෝරන්න';

  @override
  String get findWorkers => 'දක්ෂ කම්කරුවන් සොයන්න';

  @override
  String get findWorkersDesc =>
      'රැකියා පළකරන්න, මිල ගණන් ලබාගන්න, ළඟම කම්කරුවන් බඳවාගන්න';

  @override
  String get offerServices => 'මගේ සේවා ලබා දෙන්න';

  @override
  String get offerServicesDesc => 'රැකියා ලබාගන්න, ලංසු තබන්න, මුදල් උපයන්න';

  @override
  String get continueBtn => 'ඉදිරියට';

  @override
  String get selectLanguage => 'භාෂාව තෝරන්න';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'සිංහල';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get languageChanged => 'භාෂාව වෙනස් කරන ලදී';

  @override
  String get home => 'මුල් පිටුව';

  @override
  String get jobs => 'රැකියා';

  @override
  String get wallet => 'මුදල් පසුම්බිය';

  @override
  String get chat => 'කතාබහ';

  @override
  String get profile => 'විස්තර';

  @override
  String get postJob => 'රැකියාවක් පළ කරන්න';

  @override
  String get myJobs => 'මගේ රැකියා';

  @override
  String get availableJobs => 'පවතින රැකියා';

  @override
  String get jobDetails => 'රැකියා විස්තර';

  @override
  String get placeBid => 'ලංසුවක් තබන්න';

  @override
  String get acceptBid => 'ලංසුව පිළිගන්න';

  @override
  String get unlockDetails => 'විස්තර අගුළු හරින්න';

  @override
  String get unlockFree => 'අගුළු හරින්න — නොමිලේ (Pro Pass)';

  @override
  String unlockForAmount(String amount) {
    return 'අගුළු හරින්න — රු. $amount';
  }

  @override
  String get insufficientBalance => 'ප්‍රමාණවත් ශේෂයක් නැත';

  @override
  String get topUpNow => 'දැන් ටොප් අප් කරන්න';

  @override
  String get upgradeProPass => 'Pro Pass වෙත උසස් කරන්න';

  @override
  String get walletBalance => 'මුදල් පසුම්බි ශේෂය';

  @override
  String get topUp => 'ටොප් අප්';

  @override
  String get transactionHistory => 'ගනුදෙනු ඉතිහාසය';

  @override
  String get proPass => 'වැඩ්ඩෙක් Pro Pass';

  @override
  String get proPassDesc =>
      'නොමිලේ ලීඩ්, ප්‍රමුඛතා ශ්‍රේණිගත කිරීම, සත්‍යාපිත ලාංඡනය';

  @override
  String get proPassPrice => 'රු. 1,500/මාසිකව';

  @override
  String get subscribe => 'දායක වන්න';

  @override
  String get cancelSubscription => 'දායකත්වය නවත්වන්න';

  @override
  String get reviews => 'සමාලෝචන';

  @override
  String get submitReview => 'සමාලෝචනය යවන්න';

  @override
  String get rateExperience => 'ඔබේ අත්දැකීම තක්සේරු කරන්න';

  @override
  String get notifications => 'දැනුම්දීම්';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get signOut => 'පිට වෙන්න';

  @override
  String get totalCredits => 'මුළු ණය';

  @override
  String get bonus => 'ප්‍රසාද';

  @override
  String get leadFee => 'ලීඩ් ගාස්තුව';

  @override
  String get refund => 'ආපසු ගෙවීම';

  @override
  String get customer => 'පාරිභෝගිකයා';

  @override
  String get worker => 'කම්කරුවා';

  @override
  String get markComplete => 'සම්පූර්ණ කළ බවට සලකුණු කරන්න';

  @override
  String get reportIssue => 'ගැටලුවක් වාර්තා කරන්න';

  @override
  String get cancel => 'අවලංගු';

  @override
  String get confirm => 'තහවුරු කරන්න';

  @override
  String get save => 'සුරකින්න';

  @override
  String get done => 'අවසන්';

  @override
  String get error => 'දෝෂය';

  @override
  String get success => 'සාර්ථකයි';

  @override
  String get loading => 'පූරණය වෙමින්...';

  @override
  String get noResults => 'ප්‍රතිඵල හමු නොවීය';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get cashPaymentNote => 'ගෙවීම සෘජුවම කම්කරුවාට මුදලින් කරනු ලැබේ';

  @override
  String get tierWaddek => 'වැඩ්ඩෙක්';

  @override
  String get tierProfessional => 'වෘත්තීය';

  @override
  String get tierSupiri => 'සුපිරි';

  @override
  String get messages => 'පණිවිඩ';

  @override
  String get alerts => 'ඇඟවීම්';

  @override
  String get myBids => 'මගේ ලංසු';

  @override
  String get language => 'භාෂාව';

  @override
  String get account => 'ගිණුම';

  @override
  String get about => 'අප ගැන';

  @override
  String get version => 'අනුවාදය';

  @override
  String get logOutTitle => 'පිට වෙන්නද?';

  @override
  String get logOutMessage =>
      'නැවත මෙය භාවිතා කිරීමට ඔබට යළිත් ඇතුළු වීමට සිදුවේ.';

  @override
  String get logOut => 'පිට වෙන්න';

  @override
  String get myProfile => 'මගේ විස්තර';

  @override
  String get quickActions => 'ඉක්මන් ක්‍රියා';

  @override
  String get editProfile => 'විස්තර වෙනස් කරන්න';

  @override
  String get portfolio => 'කාර්ය එකතුව';

  @override
  String get mySkills => 'මගේ දක්ෂතා';

  @override
  String get updateLocation => 'ස්ථානය යාවත් කරන්න';

  @override
  String get switchToCustomerMode => 'පාරිභෝගිකයෙකු ලෙස මාරු වන්න';

  @override
  String get rating => 'ශ්‍රේණිය';

  @override
  String get status => 'තත්ත්වය';

  @override
  String get online => 'සක්‍රීය';

  @override
  String get offline => 'අක්‍රීය';

  @override
  String get morningGreeting => 'සුභ උදෑසනක්,';

  @override
  String get afternoonGreeting => 'සුභ දහවලක්,';

  @override
  String get eveningGreeting => 'සුභ සැන්දෑවක්,';

  @override
  String get fallbackName => 'ඔබ';

  @override
  String get noProfileFound => 'විස්තර හමු නොවීය';

  @override
  String get becomeAWorker => 'වැඩ්ඩෙක් වන්න';

  @override
  String get becomeAWorkerDesc =>
      'ඔබේ දක්ෂතා ඉදිරිපත් කර වැඩ්ඩෙක් හරහා ආදායමක් උපයන්න';

  @override
  String get verifiedLabel => 'තහවුරුයි';

  @override
  String get verifyIdentity => 'ඔබේ අනන්‍යතාව තහවුරු කරන්න';

  @override
  String get welcomeBack => 'ආයුබෝවන්';

  @override
  String get loginSubtitle => 'ඔබේ දුරකථන අංකය හෝ ඊමේල් එක යොදා ඇතුළු වන්න';

  @override
  String get phoneOrEmailHint => 'දුරකථන අංකය හෝ ඊමේල්';

  @override
  String get phoneOrEmailRequired => 'දුරකථන අංකය හෝ ඊමේල් ඇතුළත් කරන්න';

  @override
  String get password => 'මුරපදය';

  @override
  String get passwordRequired => 'මුරපදය ඇතුළත් කරන්න';

  @override
  String get forgotPassword => 'මුරපදය අමතකද?';

  @override
  String get logIn => 'ඇතුළු වන්න';

  @override
  String get noAccount => 'ගිණුමක් නැද්ද? ';

  @override
  String get signUp => 'ලියාපදිංචි වන්න';

  @override
  String get workerActivationDesc =>
      'වැඩ්ඩෙක් ලෙස සේවා ලබා දීමට NIC උඩුගත කිරීම සහ දක්ෂතා තෝරාගැනීම ඇතුළු සත්‍යාපනය සම්පූර්ණ කළ යුතුයි.';

  @override
  String get startVerification => 'සත්‍යාපනය ආරම්භ කරන්න';

  @override
  String get notNow => 'පසුව';

  @override
  String get phoneUpdated => 'දුරකථන අංකය යාවත් වුණා.';

  @override
  String get agreeToTermsRequired => 'කරුණාකර සේවා නියමයන් පිළිගන්න';

  @override
  String get createAccount => 'ඔබේ ගිණුම සාදන්න';

  @override
  String phoneVerified(String phone) {
    return 'දුරකථන අංකය තහවුරුයි: $phone';
  }

  @override
  String get completeProfile => 'ආරම්භ කිරීමට ඔබේ විස්තර සම්පූර්ණ කරන්න';

  @override
  String get fullLegalName => 'සම්පූර්ණ නම';

  @override
  String get fullNameRequired => 'ඔබේ සම්පූර්ණ නම ඇතුළත් කරන්න';

  @override
  String get firstAndLastNameRequired =>
      'මුල් නම සහ අන්තිම නම දෙකම ඇතුළත් කරන්න';

  @override
  String get fullNameHint => 'උදා. කමල් පෙරේරා';

  @override
  String get emailAddress => 'ඊමේල් ලිපිනය';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordMinLength => 'මුරපදය අවම වශයෙන් අකුරු 8ක් විය යුතුයි';

  @override
  String get passwordHint => 'අවම අකුරු 8';

  @override
  String get confirmPassword => 'මුරපදය තහවුරු කරන්න';

  @override
  String get passwordsDontMatch => 'මුරපද දෙක නොගැලපේ';

  @override
  String get reEnterPassword => 'මුරපදය නැවත ඇතුළත් කරන්න';

  @override
  String get termsConsent =>
      'මම සේවා නියමයන් සහ රහස්‍යතා ප්‍රතිපත්ති පිළිගනිමි';

  @override
  String get createAccountCta => 'ගිණුම සාදන්න';

  @override
  String get pwWeak => 'දුර්වලයි';

  @override
  String get pwFair => 'මධ්‍යමයි';

  @override
  String get pwGood => 'හොඳයි';

  @override
  String get pwStrong => 'ශක්තිමත්';

  @override
  String get resetPasswordTitle => 'මුරපදය යළි සකසන්න';

  @override
  String get resetPasswordDesc =>
      'ඔබේ ගිණුමට අදාළ දුරකථන අංකය ඇතුළත් කරන්න. නව මුරපදයක් සැකසීමට කේතයක් යවනු ලැබේ.';

  @override
  String get phoneHint => 'උදා. 0771234567';

  @override
  String get sendResetCode => 'යළි සැකසීමේ කේතය යවන්න';

  @override
  String get setNewPasswordTitle => 'නව මුරපදයක් සකසන්න';

  @override
  String get newPasswordDesc => 'අවම වශයෙන් අකුරු 8ක මුරපදයක් තෝරන්න.';

  @override
  String get enterPasswordValidator => 'මුරපදයක් ඇතුළත් කරන්න';

  @override
  String get useAtLeast8Chars => 'අවම වශයෙන් අකුරු 8ක් යොදන්න';

  @override
  String get newPasswordHint => 'නව මුරපදය';

  @override
  String get confirmNewPasswordHint => 'නව මුරපදය තහවුරු කරන්න';

  @override
  String get updatePassword => 'මුරපදය යාවත් කරන්න';

  @override
  String get passwordUpdatedMsg => 'මුරපදය යාවත් වුණා. ඔබ දැන් ඇතුළු වී ඇත.';

  @override
  String get category => 'කාණ්ඩය';

  @override
  String get jobTitle => 'රැකියා මාතෘකාව';

  @override
  String get jobTitleHint => 'උදා. මුළුතැන්ගේ වැට් එක හදන්න';

  @override
  String get descriptionOptional => 'විස්තරය (අත්‍යවශ්‍ය නැත)';

  @override
  String get descriptionHint => 'රැකියාව ගැන විස්තර කරන්න...';

  @override
  String get minBudget => 'අවම මුදල (රු.)';

  @override
  String get maxBudget => 'උපරිම මුදල (රු.)';

  @override
  String get address => 'ලිපිනය';

  @override
  String get addressHint => 'රැකියාව තියෙන තැන කොහෙද?';

  @override
  String get useCurrentLocation => 'දැන් ඉන්න තැන යොදන්න';

  @override
  String get addPhotosOptional => 'ඡායාරූප එකතු කරන්න (අත්‍යවශ්‍ය නැත)';

  @override
  String photosAttached(int count) {
    return 'ඡායාරූප $countක් එකතු කර ඇත';
  }

  @override
  String get selectCategory => 'කරුණාකර කාණ්ඩයක් තෝරන්න';

  @override
  String get enterTitle => 'කරුණාකර මාතෘකාවක් ඇතුළත් කරන්න';

  @override
  String get profileNotLoaded => 'පැතිකඩ පූරණය වී නැත';

  @override
  String get jobPosted => 'රැකියාව පළ කරන ලදී.';

  @override
  String get locationPermissionDenied => 'ස්ථාන අවසරය ප්‍රතික්ෂේප වුණා';

  @override
  String get locationSet => 'ස්ථානය සකස් කළා.';

  @override
  String get verifyToPostJob =>
      'රැකියාවක් පළ කිරීමට ඔබේ අනන්‍යතාව තහවුරු කරන්න';

  @override
  String get recoverAccount => 'ගිණුම යළි ලබා ගන්න';

  @override
  String get noJobsYet => 'තවම රැකියා නෑ';

  @override
  String get postFirstJob => 'කම්කරුවන් සොයන්න ඔබේ පළමු රැකියාව පළ කරන්න';

  @override
  String get noAvailableJobs => 'දැනට ලබා ගත හැකි රැකියා නෑ';

  @override
  String get noJobsNotifyDesc =>
      'ඔබේ දක්ෂතාවලට ගැලපෙන රැකියා ආ විට අපි දැනුම් දෙන්නෙමු';

  @override
  String get unknown => 'නොදනී';

  @override
  String get bidsLoadError => 'ලංසු පූරණයේදී දෝෂයක්';

  @override
  String get noBidsYet => 'තවම ලංසු නෑ';

  @override
  String get noBidsDesc => 'ලබා ගත හැකි රැකියා බලා ලංසු දාලා සල්ලි හොයන්න.';

  @override
  String get browseJobs => 'රැකියා බලන්න';

  @override
  String get total => 'මුළු';

  @override
  String get pending => 'පොරොත්තු';

  @override
  String get won => 'දිනූ';

  @override
  String get accepted => 'පිළිගත්';

  @override
  String get rejected => 'ප්‍රතික්ෂේපිත';

  @override
  String get locked => 'අගුළු ලා ඇත';

  @override
  String get jobNotFound => 'රැකියාව හමු නොවීය';

  @override
  String get description => 'විස්තරය';

  @override
  String get bids => 'ලංසු';

  @override
  String get workersWillBid => 'ඔබ රැකියාව බෙදා හරින විට කම්කරුවන් ලංසු තබයි';

  @override
  String get decline => 'ප්‍රතික්ෂේප කරන්න';

  @override
  String get declineBidConfirm => 'ලංසුව ප්‍රතික්ෂේප කරන්නද?';

  @override
  String get acceptBidShort => 'පිළිගන්න';

  @override
  String get budget => 'මුදල';

  @override
  String get scheduled => 'කල්තබා ඇත';

  @override
  String get broadcastToWorkers => 'කම්කරුවන්ට බෙදා හරින්න';

  @override
  String byCustomer(String name) {
    return '$name විසින්';
  }

  @override
  String get walletTitle => 'වැඩ්ඩෙක් මුදල් පසුම්බිය';

  @override
  String get availableBalance => 'තිබෙන ශේෂය';

  @override
  String get unlocksUsed => 'භාවිතා කළ අගුළු';

  @override
  String get daysLeft => 'ඉතිරි දින';

  @override
  String get active => 'ක්‍රියාත්මකයි';

  @override
  String get cancelling => 'අවලංගු වෙමින්';

  @override
  String get benefitsActiveUntil => 'කාලය අවසන් වන තුරු සහන ක්‍රියාත්මකයි.';

  @override
  String get upgradeToProPass => 'Pro Pass වෙත උසස් වන්න';

  @override
  String get proPassUpsellDesc =>
      'නොමිලේ ලීඩ් • ප්‍රමුඛතා පෙන්වීම • තහවුරු ලාංඡනය\nමාසිකව රු. 1,500ට';

  @override
  String get learnMore => 'තවත් දැනගන්න';

  @override
  String get noConversations => 'තවම සංවාද නෑ';

  @override
  String get chatWillAppear => 'ඔබ රැකියාවකට ගැලපුණු විට කතාබහ මෙහි පෙන්වයි';

  @override
  String get noNotificationsYet => 'තවම දැනුම්දීම් නෑ';

  @override
  String get wellNotifyYou => 'අලුත් දෙයක් වුණොත් අපි දැනුම් දෙන්නෙමු';

  @override
  String get markAllRead => 'සියල්ල කියවූ ලෙස සලකුණු කරන්න';

  @override
  String get searchHint => 'කම්කරුවන්, සේවා සොයන්න...';

  @override
  String get popularServices => 'ජනප්‍රිය සේවා';

  @override
  String get proPassTagline => 'ඔබේ ව්‍යාපාරය වර්ධනය කරගන්න හොඳම ක්‍රමය';

  @override
  String proPassPriceMonthly(String price) {
    return 'මාසිකව රු. $price';
  }

  @override
  String get zeroLeadFees => 'ලීඩ් ගාස්තු නැත';

  @override
  String get zeroLeadFeesDesc =>
      'පාරිභෝගික විස්තර නොමිලේ අගුළු හරින්න — මාසිකව 50ක් දක්වා.';

  @override
  String get priorityRanking => 'ප්‍රමුඛතා ශ්‍රේණිගත කිරීම';

  @override
  String get priorityRankingDesc =>
      'ඔබේ ලංසු මුලින්ම පෙන්වයි. PAYG කම්කරුවන්ට කලින් දැනුම් දෙයි.';

  @override
  String get verifiedBadgeBenefit => 'තහවුරු ලාංඡනය';

  @override
  String get verifiedBadgeBenefitDesc =>
      'ඔබේ විස්තර සහ ලංසු මත Pro ලාංඡනයක් සමග කැපී පෙනෙන්න.';

  @override
  String get saveMoney => 'මුදල් ඉතිරි කරන්න';

  @override
  String get saveMoneyDesc =>
      'මාසයකට 20+ රැකියා කරනවද? Pro Pass ලීඩ් ගාස්තු වලට වඩා ලාභයි.';

  @override
  String get breakEvenTitle => 'මුදල් ආපසු එන ස්ථානය';

  @override
  String get breakEvenDesc =>
      'ලීඩ් එකකට රු. 75ක නම්, අගුළු 20ක් පමණක් හරිද්දී Pro Pass සඳහා ගෙවූ මුදල ආපසු එයි. ඉතිරි 30ක් නොමිලේ ලැබේ!';

  @override
  String get verifyToSubscribe => 'දායක වීමට ඔබේ අනන්‍යතාව තහවුරු කරන්න';

  @override
  String get proPassOnlyForVerified =>
      'Pro Pass තහවුරු කළ පරිශීලකයින්ට පමණයි. මිනිත්තුවක් වැනි කාලයක් ගතවේ.';

  @override
  String get subscribeToProPass => 'Pro Pass සඳහා දායක වන්න';

  @override
  String get cancelAnytime => 'ඕනෑම වෙලාවක අවලංගු කළ හැක. බැඳීමක් නෑ.';

  @override
  String get payHereInitiated => 'PayHere දායක ගෙවීම ආරම්භ කරන ලදී';

  @override
  String get searchFailed => 'සෙවීම අසාර්ථකයි';

  @override
  String get noWorkersFound => 'කම්කරුවන් හමු නොවීය';

  @override
  String get tryDifferentSearch => 'වෙනත් වචනයකින් උත්සාහ කරන්න';

  @override
  String get identityVerification => 'අනන්‍යතා තහවුරු කිරීම';

  @override
  String get pickDocument => 'ඔබ භාවිතා කරන ලේඛනය තෝරන්න';

  @override
  String get startVerificationBtn => 'තහවුරු කිරීම ආරම්භ කරන්න';

  @override
  String get waitingForVerification => 'තහවුරු වීම සඳහා බලා සිටිමින්…';

  @override
  String attemptsUsed(int used, int total) {
    return 'භාවිතා කළ අවස්ථා: $totalකින් $used';
  }

  @override
  String get postJobShort => 'රැකියාවක් දාන්න';

  @override
  String get proPassShort => 'Pro Pass';

  @override
  String get nearestWorkers => 'ආසන්නම කම්කරුවන්';

  @override
  String get onlineOnly => 'සක්‍රීය අය පමණයි';

  @override
  String get all => 'සියල්ල';

  @override
  String get findServiceOrWorker => 'සේවාවක් හෝ කම්කරුවෙකු සොයන්න...';

  @override
  String jobsCountLabel(int count) {
    return 'රැකියා $countක්';
  }

  @override
  String get noWorkersMatch => 'මෙම පෙරහනට ගැලපෙන කම්කරුවන් නෑ';

  @override
  String get tryDifferentCategory =>
      'වෙනත් කාණ්ඩයක් උත්සාහ කරන්න හෝ \"සක්‍රීය අය පමණයි\" අක්‍රීය කරන්න.';

  @override
  String get enableLocation => 'ආසන්නයේ කම්කරුවන් බැලීමට ස්ථානය සක්‍රීය කරන්න';

  @override
  String get enableLocationDesc =>
      'වැඩ්ඩෙක් ඔබට ආසන්න කම්කරුවන් දුර අනුව පෙන්වයි. ස්ථානය නැතිව අපට ශ්‍රේණිගත කළ නොහැක.';

  @override
  String get tryAgain => 'නැවත උත්සාහ කරන්න';
}
