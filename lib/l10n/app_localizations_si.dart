// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'වද්දෙක්.lk';

  @override
  String get appTagline => 'ඔබට ආසන්නයේ දක්ෂ කම්කරුවන් සොයන්න';

  @override
  String get welcome => 'වද්දෙක් වෙත සාදරයෙන් පිළිගනිමු';

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
  String get chooseRole => 'ඔබ වද්දෙක් භාවිතා කරන ආකාරය තෝරන්න';

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
  String get chat => 'චැට්';

  @override
  String get profile => 'පැතිකඩ';

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
  String get proPass => 'වද්දෙක් Pro Pass';

  @override
  String get proPassDesc =>
      'නොමිලේ ලීඩ්, ප්‍රමුඛතා ශ්‍රේණිගත කිරීම, සත්‍යාපිත ලාංඡනය';

  @override
  String get proPassPrice => 'රු. 1,500/මාසිකව';

  @override
  String get subscribe => 'දායක වන්න';

  @override
  String get cancelSubscription => 'දායකත්වය අවලංගු කරන්න';

  @override
  String get reviews => 'සමාලෝචන';

  @override
  String get submitReview => 'සමාලෝචනය ඉදිරිපත් කරන්න';

  @override
  String get rateExperience => 'ඔබේ අත්දැකීම ශ්‍රේණිගත කරන්න';

  @override
  String get notifications => 'දැනුම්දීම්';

  @override
  String get settings => 'සැකසීම්';

  @override
  String get signOut => 'පිටවන්න';

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
  String get tierWaddek => 'වද්දෙක්';

  @override
  String get tierProfessional => 'වෘත්තීය';

  @override
  String get tierSupiri => 'සුපිරි';
}
