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

  @override
  String get messages => 'Messages';

  @override
  String get alerts => 'Alerts';

  @override
  String get myBids => 'My Bids';

  @override
  String get language => 'Language';

  @override
  String get account => 'Account';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get logOutTitle => 'Log out?';

  @override
  String get logOutMessage => 'You\'ll need to sign in again to use the app.';

  @override
  String get logOut => 'Log out';

  @override
  String get myProfile => 'My Profile';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get mySkills => 'My Skills';

  @override
  String get updateLocation => 'Update Location';

  @override
  String get switchToCustomerMode => 'Switch to Customer Mode';

  @override
  String get rating => 'Rating';

  @override
  String get status => 'Status';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get morningGreeting => 'Good morning,';

  @override
  String get afternoonGreeting => 'Good afternoon,';

  @override
  String get eveningGreeting => 'Good evening,';

  @override
  String get fallbackName => 'there';

  @override
  String get noProfileFound => 'No profile found';

  @override
  String get becomeAWorker => 'Become a Waddek';

  @override
  String get becomeAWorkerDesc => 'Offer your skills and earn on Waddek';

  @override
  String get verifiedLabel => 'Verified';

  @override
  String get verifyIdentity => 'Verify your identity';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Log in with your phone or email';

  @override
  String get phoneOrEmailHint => 'Phone number or email';

  @override
  String get phoneOrEmailRequired => 'Enter your phone number or email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log In';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get workerActivationDesc =>
      'To offer services on Waddek, you need to complete worker verification including NIC upload and skill selection.';

  @override
  String get startVerification => 'Start Verification';

  @override
  String get notNow => 'Not Now';

  @override
  String get phoneUpdated => 'Phone updated.';

  @override
  String get agreeToTermsRequired => 'Please agree to the Terms of Service';

  @override
  String get createAccount => 'Create Your Account';

  @override
  String phoneVerified(String phone) {
    return 'Phone verified: $phone';
  }

  @override
  String get completeProfile => 'Complete your profile to get started';

  @override
  String get fullLegalName => 'Full Legal Name';

  @override
  String get fullNameRequired => 'Enter your full name';

  @override
  String get firstAndLastNameRequired => 'Enter first and last name';

  @override
  String get fullNameHint => 'e.g. Kamal Perera';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordHint => 'Min 8 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get reEnterPassword => 'Re-enter password';

  @override
  String get termsConsent =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get createAccountCta => 'Create Account';

  @override
  String get pwWeak => 'Weak';

  @override
  String get pwFair => 'Fair';

  @override
  String get pwGood => 'Good';

  @override
  String get pwStrong => 'Strong';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordDesc =>
      'Enter the phone number on your account. We\'ll text you a code to set a new password.';

  @override
  String get phoneHint => 'e.g. 0771234567';

  @override
  String get sendResetCode => 'Send reset code';

  @override
  String get setNewPasswordTitle => 'Set a new password';

  @override
  String get newPasswordDesc =>
      'Choose a password that\'s at least 8 characters.';

  @override
  String get enterPasswordValidator => 'Enter a password';

  @override
  String get useAtLeast8Chars => 'Use at least 8 characters';

  @override
  String get newPasswordHint => 'New password';

  @override
  String get confirmNewPasswordHint => 'Confirm new password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get passwordUpdatedMsg => 'Password updated. You are now signed in.';

  @override
  String get category => 'Category';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get jobTitleHint => 'e.g. Fix leaking tap in kitchen';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get descriptionHint => 'Describe the job in detail...';

  @override
  String get minBudget => 'Min Budget (Rs.)';

  @override
  String get maxBudget => 'Max Budget (Rs.)';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Where is the job?';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get addPhotosOptional => 'Add Photos (optional)';

  @override
  String photosAttached(int count) {
    return '$count photo(s) attached';
  }

  @override
  String get selectCategory => 'Please select a category';

  @override
  String get enterTitle => 'Please enter a title';

  @override
  String get profileNotLoaded => 'Profile not loaded';

  @override
  String get jobPosted => 'Job posted.';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationSet => 'Location set.';

  @override
  String get verifyToPostJob => 'Verify your identity to post a job';

  @override
  String get recoverAccount => 'Recover account';

  @override
  String get noJobsYet => 'No jobs yet';

  @override
  String get postFirstJob => 'Post your first job to find workers';

  @override
  String get noAvailableJobs => 'No available jobs right now';

  @override
  String get noJobsNotifyDesc =>
      'We\'ll notify you when new jobs match your skills';

  @override
  String get unknown => 'Unknown';

  @override
  String get bidsLoadError => 'Error loading bids';

  @override
  String get noBidsYet => 'No bids yet';

  @override
  String get noBidsDesc =>
      'Browse available jobs and start placing bids to earn.';

  @override
  String get browseJobs => 'Browse Jobs';

  @override
  String get total => 'Total';

  @override
  String get pending => 'Pending';

  @override
  String get won => 'Won';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get locked => 'Locked';

  @override
  String get jobNotFound => 'Job not found';

  @override
  String get description => 'Description';

  @override
  String get bids => 'Bids';

  @override
  String get workersWillBid => 'Workers will bid once you broadcast';

  @override
  String get decline => 'Decline';

  @override
  String get declineBidConfirm => 'Decline bid?';

  @override
  String get acceptBidShort => 'Accept';

  @override
  String get budget => 'Budget';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get broadcastToWorkers => 'Broadcast to Workers';

  @override
  String byCustomer(String name) {
    return 'by $name';
  }

  @override
  String get walletTitle => 'Waddek Wallet';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get unlocksUsed => 'Unlocks Used';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get active => 'ACTIVE';

  @override
  String get cancelling => 'CANCELLING';

  @override
  String get benefitsActiveUntil => 'Benefits active until period end.';

  @override
  String get upgradeToProPass => 'Upgrade to Pro Pass';

  @override
  String get proPassUpsellDesc =>
      'Zero lead fees • Priority ranking • Verified badge\nAll for Rs. 1,500/month';

  @override
  String get learnMore => 'Learn More';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get chatWillAppear => 'Chat will appear when you match with a job';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get wellNotifyYou => 'We\'ll notify you when something happens';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get searchHint => 'Search workers, services...';

  @override
  String get popularServices => 'Popular Services';

  @override
  String get proPassTagline => 'The smartest way to grow your business';

  @override
  String proPassPriceMonthly(String price) {
    return 'Rs. $price / month';
  }

  @override
  String get zeroLeadFees => 'Zero Lead Fees';

  @override
  String get zeroLeadFeesDesc =>
      'Unlock customer details for free — up to 50 per month.';

  @override
  String get priorityRanking => 'Priority Ranking';

  @override
  String get priorityRankingDesc =>
      'Your bids appear first. Get notified before PAYG workers.';

  @override
  String get verifiedBadgeBenefit => 'Verified Badge';

  @override
  String get verifiedBadgeBenefitDesc =>
      'Stand out with the Pro badge on your profile and bids.';

  @override
  String get saveMoney => 'Save Money';

  @override
  String get saveMoneyDesc =>
      'Doing 20+ jobs/month? Pro Pass costs less than lead fees.';

  @override
  String get breakEvenTitle => 'Break-even calculation';

  @override
  String get breakEvenDesc =>
      'At Rs. 75/lead, Pro Pass pays for itself after just 20 unlocks. That leaves you 30 more for free!';

  @override
  String get verifyToSubscribe => 'Verify your identity to subscribe';

  @override
  String get proPassOnlyForVerified =>
      'Pro Pass is for verified users only. It takes about a minute.';

  @override
  String get subscribeToProPass => 'Subscribe to Pro Pass';

  @override
  String get cancelAnytime => 'Cancel anytime. No lock-in.';

  @override
  String get payHereInitiated => 'PayHere subscription payment initiated';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get noWorkersFound => 'No workers found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get pickDocument => 'Pick the document you will use';

  @override
  String get startVerificationBtn => 'Start verification';

  @override
  String get waitingForVerification => 'Waiting for verification…';

  @override
  String attemptsUsed(int used, int total) {
    return 'Attempts used: $used of $total';
  }

  @override
  String get postJobShort => 'Post Job';

  @override
  String get proPassShort => 'Pro Pass';

  @override
  String get nearestWorkers => 'Nearest workers';

  @override
  String get onlineOnly => 'Online only';

  @override
  String get all => 'All';

  @override
  String get findServiceOrWorker => 'Find a service or worker...';

  @override
  String jobsCountLabel(int count) {
    return '$count jobs';
  }

  @override
  String get noWorkersMatch => 'No workers match this filter';

  @override
  String get tryDifferentCategory =>
      'Try a different category or turn off \"Online only\".';

  @override
  String get enableLocation => 'Enable location to see workers near you';

  @override
  String get enableLocationDesc =>
      'Waddek shows workers in your area sorted by distance. Without location we can\'t rank them.';

  @override
  String get tryAgain => 'Try again';
}
