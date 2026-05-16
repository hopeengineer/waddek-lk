import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Waddek.lk'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Find skilled workers near you'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Waddek'**
  String get welcome;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to get started'**
  String get enterPhone;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'77 123 4567'**
  String get phonePlaceholder;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendCode;

  /// No description provided for @verifyNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyNumber;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Sri Lankan phone number'**
  String get invalidPhone;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @codeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get codeMustBe6Digits;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get otpSendFailed;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please try again.'**
  String get verificationFailed;

  /// No description provided for @iWantTo.
  ///
  /// In en, this message translates to:
  /// **'I want to…'**
  String get iWantTo;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'ll use Waddek'**
  String get chooseRole;

  /// No description provided for @findWorkers.
  ///
  /// In en, this message translates to:
  /// **'Find skilled workers'**
  String get findWorkers;

  /// No description provided for @findWorkersDesc.
  ///
  /// In en, this message translates to:
  /// **'Post jobs, get quotes, hire nearby workers'**
  String get findWorkersDesc;

  /// No description provided for @offerServices.
  ///
  /// In en, this message translates to:
  /// **'Offer my services'**
  String get offerServices;

  /// No description provided for @offerServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get job leads, place bids, earn money'**
  String get offerServicesDesc;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// No description provided for @availableJobs.
  ///
  /// In en, this message translates to:
  /// **'Available Jobs'**
  String get availableJobs;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @placeBid.
  ///
  /// In en, this message translates to:
  /// **'Place Bid'**
  String get placeBid;

  /// No description provided for @acceptBid.
  ///
  /// In en, this message translates to:
  /// **'Accept Bid'**
  String get acceptBid;

  /// No description provided for @unlockDetails.
  ///
  /// In en, this message translates to:
  /// **'Unlock Details'**
  String get unlockDetails;

  /// No description provided for @unlockFree.
  ///
  /// In en, this message translates to:
  /// **'Unlock — Free (Pro Pass)'**
  String get unlockFree;

  /// No description provided for @unlockForAmount.
  ///
  /// In en, this message translates to:
  /// **'Unlock — Rs. {amount}'**
  String unlockForAmount(String amount);

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @topUpNow.
  ///
  /// In en, this message translates to:
  /// **'Top Up Now'**
  String get topUpNow;

  /// No description provided for @upgradeProPass.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro Pass'**
  String get upgradeProPass;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @proPass.
  ///
  /// In en, this message translates to:
  /// **'Waddek Pro Pass'**
  String get proPass;

  /// No description provided for @proPassDesc.
  ///
  /// In en, this message translates to:
  /// **'Zero lead fees, priority ranking, verified badge'**
  String get proPassDesc;

  /// No description provided for @proPassPrice.
  ///
  /// In en, this message translates to:
  /// **'Rs. 1,500/month'**
  String get proPassPrice;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rateExperience;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @leadFee.
  ///
  /// In en, this message translates to:
  /// **'Lead Fee'**
  String get leadFee;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markComplete;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cashPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Payment is made in cash directly to the worker'**
  String get cashPaymentNote;

  /// No description provided for @tierWaddek.
  ///
  /// In en, this message translates to:
  /// **'Waddek'**
  String get tierWaddek;

  /// No description provided for @tierProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get tierProfessional;

  /// No description provided for @tierSupiri.
  ///
  /// In en, this message translates to:
  /// **'Supiri'**
  String get tierSupiri;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @myBids.
  ///
  /// In en, this message translates to:
  /// **'My Bids'**
  String get myBids;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to use the app.'**
  String get logOutMessage;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @mySkills.
  ///
  /// In en, this message translates to:
  /// **'My Skills'**
  String get mySkills;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @switchToCustomerMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to Customer Mode'**
  String get switchToCustomerMode;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @morningGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get morningGreeting;

  /// No description provided for @afternoonGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get afternoonGreeting;

  /// No description provided for @eveningGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get eveningGreeting;

  /// No description provided for @fallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get fallbackName;

  /// No description provided for @noProfileFound.
  ///
  /// In en, this message translates to:
  /// **'No profile found'**
  String get noProfileFound;

  /// No description provided for @becomeAWorker.
  ///
  /// In en, this message translates to:
  /// **'Become a Waddek'**
  String get becomeAWorker;

  /// No description provided for @becomeAWorkerDesc.
  ///
  /// In en, this message translates to:
  /// **'Offer your skills and earn on Waddek'**
  String get becomeAWorkerDesc;

  /// No description provided for @verifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedLabel;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyIdentity;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your phone or email'**
  String get loginSubtitle;

  /// No description provided for @phoneOrEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email'**
  String get phoneOrEmailHint;

  /// No description provided for @phoneOrEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number or email'**
  String get phoneOrEmailRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @workerActivationDesc.
  ///
  /// In en, this message translates to:
  /// **'To offer services on Waddek, you need to complete worker verification including NIC upload and skill selection.'**
  String get workerActivationDesc;

  /// No description provided for @startVerification.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get startVerification;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone updated.'**
  String get phoneUpdated;

  /// No description provided for @agreeToTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get agreeToTermsRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createAccount;

  /// No description provided for @phoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified: {phone}'**
  String phoneVerified(String phone);

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get started'**
  String get completeProfile;

  /// No description provided for @fullLegalName.
  ///
  /// In en, this message translates to:
  /// **'Full Legal Name'**
  String get fullLegalName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameRequired;

  /// No description provided for @firstAndLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter first and last name'**
  String get firstAndLastNameRequired;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kamal Perera'**
  String get fullNameHint;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reEnterPassword;

  /// No description provided for @termsConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get termsConsent;

  /// No description provided for @createAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountCta;

  /// No description provided for @pwWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get pwWeak;

  /// No description provided for @pwFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get pwFair;

  /// No description provided for @pwGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get pwGood;

  /// No description provided for @pwStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get pwStrong;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number on your account. We\'ll text you a code to set a new password.'**
  String get resetPasswordDesc;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0771234567'**
  String get phoneHint;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get sendResetCode;

  /// No description provided for @setNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPasswordTitle;

  /// No description provided for @newPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a password that\'s at least 8 characters.'**
  String get newPasswordDesc;

  /// No description provided for @enterPasswordValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPasswordValidator;

  /// No description provided for @useAtLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get useAtLeast8Chars;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You are now signed in.'**
  String get passwordUpdatedMsg;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fix leaking tap in kitchen'**
  String get jobTitleHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the job in detail...'**
  String get descriptionHint;

  /// No description provided for @minBudget.
  ///
  /// In en, this message translates to:
  /// **'Min Budget (Rs.)'**
  String get minBudget;

  /// No description provided for @maxBudget.
  ///
  /// In en, this message translates to:
  /// **'Max Budget (Rs.)'**
  String get maxBudget;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Where is the job?'**
  String get addressHint;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @addPhotosOptional.
  ///
  /// In en, this message translates to:
  /// **'Add Photos (optional)'**
  String get addPhotosOptional;

  /// No description provided for @photosAttached.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) attached'**
  String photosAttached(int count);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategory;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @profileNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Profile not loaded'**
  String get profileNotLoaded;

  /// No description provided for @jobPosted.
  ///
  /// In en, this message translates to:
  /// **'Job posted.'**
  String get jobPosted;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationSet.
  ///
  /// In en, this message translates to:
  /// **'Location set.'**
  String get locationSet;

  /// No description provided for @verifyToPostJob.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to post a job'**
  String get verifyToPostJob;

  /// No description provided for @recoverAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover account'**
  String get recoverAccount;

  /// No description provided for @noJobsYet.
  ///
  /// In en, this message translates to:
  /// **'No jobs yet'**
  String get noJobsYet;

  /// No description provided for @postFirstJob.
  ///
  /// In en, this message translates to:
  /// **'Post your first job to find workers'**
  String get postFirstJob;

  /// No description provided for @noAvailableJobs.
  ///
  /// In en, this message translates to:
  /// **'No available jobs right now'**
  String get noAvailableJobs;

  /// No description provided for @noJobsNotifyDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when new jobs match your skills'**
  String get noJobsNotifyDesc;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @bidsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading bids'**
  String get bidsLoadError;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No bids yet'**
  String get noBidsYet;

  /// No description provided for @noBidsDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse available jobs and start placing bids to earn.'**
  String get noBidsDesc;

  /// No description provided for @browseJobs.
  ///
  /// In en, this message translates to:
  /// **'Browse Jobs'**
  String get browseJobs;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @jobNotFound.
  ///
  /// In en, this message translates to:
  /// **'Job not found'**
  String get jobNotFound;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @bids.
  ///
  /// In en, this message translates to:
  /// **'Bids'**
  String get bids;

  /// No description provided for @workersWillBid.
  ///
  /// In en, this message translates to:
  /// **'Workers will bid once you broadcast'**
  String get workersWillBid;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @declineBidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Decline bid?'**
  String get declineBidConfirm;

  /// No description provided for @acceptBidShort.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptBidShort;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @broadcastToWorkers.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to Workers'**
  String get broadcastToWorkers;

  /// No description provided for @byCustomer.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String byCustomer(String name);

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Waddek Wallet'**
  String get walletTitle;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @unlocksUsed.
  ///
  /// In en, this message translates to:
  /// **'Unlocks Used'**
  String get unlocksUsed;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @cancelling.
  ///
  /// In en, this message translates to:
  /// **'CANCELLING'**
  String get cancelling;

  /// No description provided for @benefitsActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Benefits active until period end.'**
  String get benefitsActiveUntil;

  /// No description provided for @upgradeToProPass.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro Pass'**
  String get upgradeToProPass;

  /// No description provided for @proPassUpsellDesc.
  ///
  /// In en, this message translates to:
  /// **'Zero lead fees • Priority ranking • Verified badge\nAll for Rs. 1,500/month'**
  String get proPassUpsellDesc;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @chatWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Chat will appear when you match with a job'**
  String get chatWillAppear;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @wellNotifyYou.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when something happens'**
  String get wellNotifyYou;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search workers, services...'**
  String get searchHint;

  /// No description provided for @popularServices.
  ///
  /// In en, this message translates to:
  /// **'Popular Services'**
  String get popularServices;

  /// No description provided for @proPassTagline.
  ///
  /// In en, this message translates to:
  /// **'The smartest way to grow your business'**
  String get proPassTagline;

  /// No description provided for @proPassPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Rs. {price} / month'**
  String proPassPriceMonthly(String price);

  /// No description provided for @zeroLeadFees.
  ///
  /// In en, this message translates to:
  /// **'Zero Lead Fees'**
  String get zeroLeadFees;

  /// No description provided for @zeroLeadFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock customer details for free — up to 50 per month.'**
  String get zeroLeadFeesDesc;

  /// No description provided for @priorityRanking.
  ///
  /// In en, this message translates to:
  /// **'Priority Ranking'**
  String get priorityRanking;

  /// No description provided for @priorityRankingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your bids appear first. Get notified before PAYG workers.'**
  String get priorityRankingDesc;

  /// No description provided for @verifiedBadgeBenefit.
  ///
  /// In en, this message translates to:
  /// **'Verified Badge'**
  String get verifiedBadgeBenefit;

  /// No description provided for @verifiedBadgeBenefitDesc.
  ///
  /// In en, this message translates to:
  /// **'Stand out with the Pro badge on your profile and bids.'**
  String get verifiedBadgeBenefitDesc;

  /// No description provided for @saveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save Money'**
  String get saveMoney;

  /// No description provided for @saveMoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Doing 20+ jobs/month? Pro Pass costs less than lead fees.'**
  String get saveMoneyDesc;

  /// No description provided for @breakEvenTitle.
  ///
  /// In en, this message translates to:
  /// **'Break-even calculation'**
  String get breakEvenTitle;

  /// No description provided for @breakEvenDesc.
  ///
  /// In en, this message translates to:
  /// **'At Rs. 75/lead, Pro Pass pays for itself after just 20 unlocks. That leaves you 30 more for free!'**
  String get breakEvenDesc;

  /// No description provided for @verifyToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to subscribe'**
  String get verifyToSubscribe;

  /// No description provided for @proPassOnlyForVerified.
  ///
  /// In en, this message translates to:
  /// **'Pro Pass is for verified users only. It takes about a minute.'**
  String get proPassOnlyForVerified;

  /// No description provided for @subscribeToProPass.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro Pass'**
  String get subscribeToProPass;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. No lock-in.'**
  String get cancelAnytime;

  /// No description provided for @payHereInitiated.
  ///
  /// In en, this message translates to:
  /// **'PayHere subscription payment initiated'**
  String get payHereInitiated;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @noWorkersFound.
  ///
  /// In en, this message translates to:
  /// **'No workers found'**
  String get noWorkersFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerification;

  /// No description provided for @pickDocument.
  ///
  /// In en, this message translates to:
  /// **'Pick the document you will use'**
  String get pickDocument;

  /// No description provided for @startVerificationBtn.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get startVerificationBtn;

  /// No description provided for @waitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification…'**
  String get waitingForVerification;

  /// No description provided for @attemptsUsed.
  ///
  /// In en, this message translates to:
  /// **'Attempts used: {used} of {total}'**
  String attemptsUsed(int used, int total);

  /// No description provided for @postJobShort.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJobShort;

  /// No description provided for @proPassShort.
  ///
  /// In en, this message translates to:
  /// **'Pro Pass'**
  String get proPassShort;

  /// No description provided for @nearestWorkers.
  ///
  /// In en, this message translates to:
  /// **'Nearest workers'**
  String get nearestWorkers;

  /// No description provided for @onlineOnly.
  ///
  /// In en, this message translates to:
  /// **'Online only'**
  String get onlineOnly;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @findServiceOrWorker.
  ///
  /// In en, this message translates to:
  /// **'Find a service or worker...'**
  String get findServiceOrWorker;

  /// No description provided for @jobsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} jobs'**
  String jobsCountLabel(int count);

  /// No description provided for @noWorkersMatch.
  ///
  /// In en, this message translates to:
  /// **'No workers match this filter'**
  String get noWorkersMatch;

  /// No description provided for @tryDifferentCategory.
  ///
  /// In en, this message translates to:
  /// **'Try a different category or turn off \"Online only\".'**
  String get tryDifferentCategory;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see workers near you'**
  String get enableLocation;

  /// No description provided for @enableLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Waddek shows workers in your area sorted by distance. Without location we can\'t rank them.'**
  String get enableLocationDesc;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
