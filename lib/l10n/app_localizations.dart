import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor Appointment'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re excited to have you back, can\'t wait to see what you\'ve been up to since you last logged in.'**
  String get welcomeBackSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @patientRegistration.
  ///
  /// In en, this message translates to:
  /// **'Patient Registration'**
  String get patientRegistration;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get stepOf;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @accountInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your login credentials to get started.'**
  String get accountInfoSubtitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordShort;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @personalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile for a better experience.'**
  String get personalDetailsSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @locationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location on map'**
  String get locationOnMap;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @howAreYou.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get howAreYou;

  /// No description provided for @bookNearestDoctor.
  ///
  /// In en, this message translates to:
  /// **'Book and\nschedule with\nnearest doctor'**
  String get bookNearestDoctor;

  /// No description provided for @findNearby.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby'**
  String get findNearby;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for doctors, specialities...'**
  String get searchHint;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Medical Specialities'**
  String get specialties;

  /// No description provided for @recommendedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Recommended Doctors'**
  String get recommendedDoctors;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video\nCall'**
  String get videoCall;

  /// No description provided for @phoneCall.
  ///
  /// In en, this message translates to:
  /// **'Phone\nCall'**
  String get phoneCall;

  /// No description provided for @myRecords.
  ///
  /// In en, this message translates to:
  /// **'My\nRecords'**
  String get myRecords;

  /// No description provided for @findNearbyGrid.
  ///
  /// In en, this message translates to:
  /// **'Find\nNearby'**
  String get findNearbyGrid;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email, phone'**
  String get personalInfoSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get changePasswordSubtitle;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @medicalRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your health documents'**
  String get medicalRecordsSubtitle;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @paymentHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check past transactions'**
  String get paymentHistorySubtitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Doctor Profile'**
  String get doctorProfile;

  /// No description provided for @doctorFullName.
  ///
  /// In en, this message translates to:
  /// **'Doctor Full Name'**
  String get doctorFullName;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @acceptingPatients.
  ///
  /// In en, this message translates to:
  /// **'Accepting Patients'**
  String get acceptingPatients;

  /// No description provided for @currentlyAccepting.
  ///
  /// In en, this message translates to:
  /// **'Currently Accepting'**
  String get currentlyAccepting;

  /// No description provided for @notAccepting.
  ///
  /// In en, this message translates to:
  /// **'Not Accepting'**
  String get notAccepting;

  /// No description provided for @setupFeesAndServices.
  ///
  /// In en, this message translates to:
  /// **'Setup Fees & Services'**
  String get setupFeesAndServices;

  /// No description provided for @manageConsultationCosts.
  ///
  /// In en, this message translates to:
  /// **'Manage your consultation costs'**
  String get manageConsultationCosts;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @setAutoScheduleBlocks.
  ///
  /// In en, this message translates to:
  /// **'Set auto-schedule blocks'**
  String get setAutoScheduleBlocks;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancellationRequested.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Requested'**
  String get cancellationRequested;

  /// No description provided for @rescheduleApproved.
  ///
  /// In en, this message translates to:
  /// **'Reschedule Approved'**
  String get rescheduleApproved;

  /// No description provided for @rescheduleRequested.
  ///
  /// In en, this message translates to:
  /// **'Reschedule Requested'**
  String get rescheduleRequested;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @selectNewSlot.
  ///
  /// In en, this message translates to:
  /// **'Select New Slot'**
  String get selectNewSlot;

  /// No description provided for @rescheduleWindowExpired.
  ///
  /// In en, this message translates to:
  /// **'Reschedule window expired.'**
  String get rescheduleWindowExpired;

  /// No description provided for @reschedulePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your reschedule request is pending doctor approval.'**
  String get reschedulePendingApproval;

  /// No description provided for @cancellationPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Your cancellation request is pending review.'**
  String get cancellationPendingReview;

  /// No description provided for @requestReschedule.
  ///
  /// In en, this message translates to:
  /// **'Request Reschedule'**
  String get requestReschedule;

  /// No description provided for @rescheduleAllowedUpTo24Hours.
  ///
  /// In en, this message translates to:
  /// **'Rescheduling is only allowed up to 24 hours before the appointment.'**
  String get rescheduleAllowedUpTo24Hours;

  /// No description provided for @requestCancel.
  ///
  /// In en, this message translates to:
  /// **'Request Cancel'**
  String get requestCancel;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave Review'**
  String get leaveReview;

  /// No description provided for @bookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get bookAgain;

  /// No description provided for @requestCancellation.
  ///
  /// In en, this message translates to:
  /// **'Request Cancellation'**
  String get requestCancellation;

  /// No description provided for @cancelReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for cancelling your appointment with {doctorName}.'**
  String cancelReasonPrompt(String doctorName);

  /// No description provided for @cancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason...'**
  String get cancellationReasonHint;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get pleaseEnterReason;

  /// No description provided for @cancellationSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cancellation request submitted successfully'**
  String get cancellationSubmittedSuccessfully;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @rescheduleReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for rescheduling your appointment with {doctorName}.'**
  String rescheduleReasonPrompt(String doctorName);

  /// No description provided for @rescheduleReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reschedule reason...'**
  String get rescheduleReasonHint;

  /// No description provided for @rescheduleSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reschedule request submitted successfully'**
  String get rescheduleSubmittedSuccessfully;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @limitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the daily limit of messages'**
  String get limitReachedMessage;

  /// No description provided for @rateYourDoctor.
  ///
  /// In en, this message translates to:
  /// **'How was your visit with {doctorName}?'**
  String rateYourDoctor(Object doctorName);

  /// No description provided for @rateYourVisit.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Visit'**
  String get rateYourVisit;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @selectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get selectRating;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @ratingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted successfully'**
  String get ratingSubmitted;

  /// No description provided for @ratingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Rating updated successfully'**
  String get ratingUpdated;

  /// No description provided for @errorSubmittingRating.
  ///
  /// In en, this message translates to:
  /// **'Error submitting rating'**
  String get errorSubmittingRating;

  /// No description provided for @feedbackOptional.
  ///
  /// In en, this message translates to:
  /// **'Feedback is optional'**
  String get feedbackOptional;

  /// No description provided for @tellUsMore.
  ///
  /// In en, this message translates to:
  /// **'Tell us more...'**
  String get tellUsMore;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateExperience;

  /// No description provided for @skipAndRateLater.
  ///
  /// In en, this message translates to:
  /// **'Skip & Rate Later'**
  String get skipAndRateLater;

  /// No description provided for @weValueYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'We value your feedback'**
  String get weValueYourFeedback;

  /// No description provided for @feedbackHelpsUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve our service.'**
  String get feedbackHelpsUsImprove;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// No description provided for @waitingForAi.
  ///
  /// In en, this message translates to:
  /// **'waiting for AI...'**
  String get waitingForAi;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'type your message...'**
  String get typeYourMessage;

  /// No description provided for @registerHelp.
  ///
  /// In en, this message translates to:
  /// **'Registration Help'**
  String get registerHelp;

  /// No description provided for @authStepsCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Credentials'**
  String get authStepsCredentialsTitle;

  /// No description provided for @authStepsCredentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your professional email and a secure password. You\'ll also need a valid phone number for verification.'**
  String get authStepsCredentialsSubtitle;

  /// No description provided for @authStepsCredentialsHeader.
  ///
  /// In en, this message translates to:
  /// **'Account Credentails'**
  String get authStepsCredentialsHeader;

  /// No description provided for @authStepsCredentialsEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email, password and phone to get started.'**
  String get authStepsCredentialsEmail;

  /// No description provided for @authStepsCredentialsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authStepsCredentialsPhone;

  /// No description provided for @authStepsCredentialsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authStepsCredentialsPassword;

  /// No description provided for @authStepsCredentialsConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authStepsCredentialsConfirmPassword;

  /// No description provided for @authStepsPersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Personal Information'**
  String get authStepsPersonalInfoTitle;

  /// No description provided for @authStepsPersonalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share some basic details about yourself for your profile.'**
  String get authStepsPersonalInfoSubtitle;

  /// No description provided for @authStepsClinicDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Clinic Details'**
  String get authStepsClinicDetailsTitle;

  /// No description provided for @authStepsClinicDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your clinic and where you practice.'**
  String get authStepsClinicDetailsSubtitle;

  /// No description provided for @authStepsNote.
  ///
  /// In en, this message translates to:
  /// **'Note: All registrations are reviewed by our administration team before approval.'**
  String get authStepsNote;

  /// No description provided for @authStepsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get authStepsGotIt;

  /// No description provided for @authErrorsEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get authErrorsEmailInUse;

  /// No description provided for @authErrorsPhoneInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already in use'**
  String get authErrorsPhoneInUse;

  /// No description provided for @authErrorsInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authErrorsInvalidEmail;

  /// No description provided for @authErrorsInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get authErrorsInvalidPhone;

  /// No description provided for @authErrorsPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authErrorsPasswordMismatch;

  /// No description provided for @authTermsTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTermsTermsAndConditions;

  /// No description provided for @authTermsAcceptedTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms and conditions'**
  String get authTermsAcceptedTerms;

  /// No description provided for @authDoctorAuthDoctorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Doctor Registration'**
  String get authDoctorAuthDoctorRegistration;

  /// No description provided for @authDoctorAuthRegisterPending.
  ///
  /// In en, this message translates to:
  /// **'Your registration as a Doctor has been successfully submitted. Our administration team is reviewing your details to verify your medical credentials. You will receive an email once approved.'**
  String get authDoctorAuthRegisterPending;

  /// No description provided for @authDoctorAuthApplicationRecieved.
  ///
  /// In en, this message translates to:
  /// **'Application Recieved'**
  String get authDoctorAuthApplicationRecieved;

  /// No description provided for @authDoctorAuthSelectSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Please select a specialization'**
  String get authDoctorAuthSelectSpecialization;

  /// No description provided for @authDoctorAuthSelectClinicLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Clinic Location'**
  String get authDoctorAuthSelectClinicLocation;

  /// No description provided for @authDoctorAuthSelectHospitalLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital Location'**
  String get authDoctorAuthSelectHospitalLocation;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @couldNotGetCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location'**
  String get couldNotGetCurrentLocation;

  /// No description provided for @otpVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP Verified Successfully.'**
  String get otpVerifiedSuccessfully;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccessfully;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @verifyOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to {email}.'**
  String verifyOtpSubtitle(String email);

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password.'**
  String get enterNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @resetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting...'**
  String get resetting;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a verification code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @searchForAPlace.
  ///
  /// In en, this message translates to:
  /// **'Search for a place...'**
  String get searchForAPlace;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get passwordMinChars;

  /// No description provided for @meetPasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Please meet all password requirements'**
  String get meetPasswordRequirements;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get birthDateHint;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @licenseId.
  ///
  /// In en, this message translates to:
  /// **'License ID'**
  String get licenseId;

  /// No description provided for @licenseIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. LIC-123456'**
  String get licenseIdHint;

  /// No description provided for @expYears.
  ///
  /// In en, this message translates to:
  /// **'Exp. Years'**
  String get expYears;

  /// No description provided for @consultationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee'**
  String get consultationFee;

  /// No description provided for @consultationFeeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 200'**
  String get consultationFeeHint;

  /// No description provided for @professionalBio.
  ///
  /// In en, this message translates to:
  /// **'Professional Bio'**
  String get professionalBio;

  /// No description provided for @professionalBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell patients about your expertise...'**
  String get professionalBioHint;

  /// No description provided for @mainHospital.
  ///
  /// In en, this message translates to:
  /// **'Main Hospital'**
  String get mainHospital;

  /// No description provided for @mainHospitalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cairo Specialist Hospital'**
  String get mainHospitalHint;

  /// No description provided for @clinicAddress.
  ///
  /// In en, this message translates to:
  /// **'Clinic Address'**
  String get clinicAddress;

  /// No description provided for @clinicAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Tap map icon to select'**
  String get clinicAddressHint;

  /// No description provided for @passwordCheckUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase letter'**
  String get passwordCheckUppercase;

  /// No description provided for @passwordCheckLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letter'**
  String get passwordCheckLowercase;

  /// No description provided for @passwordCheckSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special character'**
  String get passwordCheckSpecial;

  /// No description provided for @passwordCheck8Chars.
  ///
  /// In en, this message translates to:
  /// **'8 characters'**
  String get passwordCheck8Chars;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @appointmentType.
  ///
  /// In en, this message translates to:
  /// **'Appointment Type'**
  String get appointmentType;

  /// No description provided for @regularVisit.
  ///
  /// In en, this message translates to:
  /// **'Regular Visit'**
  String get regularVisit;

  /// No description provided for @regularVisitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard medical checkup & follow-up'**
  String get regularVisitSubtitle;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @consultationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed diagnosis & second opinion'**
  String get consultationSubtitle;

  /// No description provided for @noAvailability.
  ///
  /// In en, this message translates to:
  /// **'Doctor has no availability'**
  String get noAvailability;

  /// No description provided for @noAvailabilityMessage.
  ///
  /// In en, this message translates to:
  /// **'This doctor hasn\'t set any slots yet.\nPlease check back later or choose another doctor.'**
  String get noAvailabilityMessage;

  /// No description provided for @noSlotsForDate.
  ///
  /// In en, this message translates to:
  /// **'No slots for this date'**
  String get noSlotsForDate;

  /// No description provided for @noSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a date marked with a dot'**
  String get noSlotsHint;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @paymentOption.
  ///
  /// In en, this message translates to:
  /// **'Payment Option'**
  String get paymentOption;

  /// No description provided for @paymentOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select how you\'d like to pay for your appointment'**
  String get paymentOptionSubtitle;

  /// No description provided for @paymobSecured.
  ///
  /// In en, this message translates to:
  /// **'Payments secured by Paymob'**
  String get paymobSecured;

  /// No description provided for @onlineCard.
  ///
  /// In en, this message translates to:
  /// **'Online Card'**
  String get onlineCard;

  /// No description provided for @onlineCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with Visa or MasterCard via Paymob'**
  String get onlineCardSubtitle;

  /// No description provided for @mobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile Wallet'**
  String get mobileWallet;

  /// No description provided for @mobileWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with Vodafone Cash, Orange Money or Etisalat Cash'**
  String get mobileWalletSubtitle;

  /// No description provided for @cashAtClinic.
  ///
  /// In en, this message translates to:
  /// **'Cash at Clinic'**
  String get cashAtClinic;

  /// No description provided for @cashAtClinicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay in person when you arrive at the clinic'**
  String get cashAtClinicSubtitle;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled. You can try again.'**
  String get paymentCancelled;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @clinicImages.
  ///
  /// In en, this message translates to:
  /// **'Clinic Images'**
  String get clinicImages;

  /// No description provided for @locationMap.
  ///
  /// In en, this message translates to:
  /// **'Location Map'**
  String get locationMap;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noSpecialitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No specialities found.'**
  String get noSpecialitiesFound;

  /// No description provided for @couldNotFindOnMap.
  ///
  /// In en, this message translates to:
  /// **'Could not find \"{query}\" on the map.'**
  String couldNotFindOnMap(String query);

  /// No description provided for @couldNotAccessLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not access your current location.'**
  String get couldNotAccessLocation;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPayment;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @backToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Back to Checkout'**
  String get backToCheckout;

  /// No description provided for @tryAgainLower.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainLower;

  /// No description provided for @paymentCancelledShort.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get paymentCancelledShort;

  /// No description provided for @availabilityGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Availability generated successfully!'**
  String get availabilityGeneratedSuccessfully;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @rescheduleApprovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reschedule approved successfully'**
  String get rescheduleApprovedSuccessfully;

  /// No description provided for @recordSimulatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Record simulated successfully!'**
  String get recordSimulatedSuccessfully;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with'**
  String get howWasYourExperience;

  /// No description provided for @writeYourReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get writeYourReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSummary.
  ///
  /// In en, this message translates to:
  /// **'Review Summary'**
  String get reviewSummary;

  /// No description provided for @doctorInformation.
  ///
  /// In en, this message translates to:
  /// **'Doctor Information'**
  String get doctorInformation;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found.'**
  String get noDoctorsFound;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get timeSlot;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @costSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get costSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @cashAtClinicInfo.
  ///
  /// In en, this message translates to:
  /// **'You selected Cash at Clinic. Your appointment will be booked and payment confirmed by the doctor when you arrive.'**
  String get cashAtClinicInfo;

  /// No description provided for @paymobPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'You will complete payment securely inside the app via Paymob. No browser redirect.'**
  String get paymobPaymentInfo;

  /// No description provided for @rescheduleNoPayment.
  ///
  /// In en, this message translates to:
  /// **'You are rescheduling your appointment. No additional payment is required.'**
  String get rescheduleNoPayment;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get confirmAndPay;

  /// No description provided for @generalConsultation.
  ///
  /// In en, this message translates to:
  /// **'General Consultation'**
  String get generalConsultation;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @egpSuffix.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egpSuffix;

  /// No description provided for @availableTime.
  ///
  /// In en, this message translates to:
  /// **'Available Time'**
  String get availableTime;

  /// No description provided for @selectDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateLabel;

  /// No description provided for @availableTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Available time'**
  String get availableTimeLabel;

  /// No description provided for @fromTime.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromTime;

  /// No description provided for @toTime.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointment;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @continueToPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPaymentLabel;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// No description provided for @backToCheckoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Back to Checkout'**
  String get backToCheckoutLabel;

  /// No description provided for @patientGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get patientGender;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @verifyingPayment.
  ///
  /// In en, this message translates to:
  /// **'Verifying Payment…'**
  String get verifyingPayment;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed!'**
  String get paymentConfirmed;

  /// No description provided for @verificationDelayed.
  ///
  /// In en, this message translates to:
  /// **'Verification Delayed'**
  String get verificationDelayed;

  /// No description provided for @paymentFailedText.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailedText;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @waitingForPaymentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation from the gateway. This usually takes a few seconds.'**
  String get waitingForPaymentConfirmation;

  /// No description provided for @appointmentConfirmedInfo.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been confirmed. You will receive a confirmation shortly.'**
  String get appointmentConfirmedInfo;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutMe;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @practicePlace.
  ///
  /// In en, this message translates to:
  /// **'Practice Place'**
  String get practicePlace;

  /// No description provided for @noAddressProvided.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get noAddressProvided;

  /// No description provided for @clinicLocation.
  ///
  /// In en, this message translates to:
  /// **'Clinic Location'**
  String get clinicLocation;

  /// No description provided for @patientNameLoading.
  ///
  /// In en, this message translates to:
  /// **'Patient Name Loading'**
  String get patientNameLoading;

  /// No description provided for @reviewCommentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Review comment content loading placeholder text.'**
  String get reviewCommentPlaceholder;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @chatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabel;

  /// No description provided for @aboutTab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTab;

  /// No description provided for @locationTab.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTab;

  /// No description provided for @reviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTab;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewsCount;

  /// No description provided for @medicalRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecordsTitle;

  /// No description provided for @addedByPrefix.
  ///
  /// In en, this message translates to:
  /// **'Added by'**
  String get addedByPrefix;

  /// No description provided for @addMedicalRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Record'**
  String get addMedicalRecordTitle;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Title'**
  String get recordTitle;

  /// No description provided for @recordTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blood Test Results'**
  String get recordTitleHint;

  /// No description provided for @doctorFacilityName.
  ///
  /// In en, this message translates to:
  /// **'Doctor/Facility Name'**
  String get doctorFacilityName;

  /// No description provided for @doctorFacilityNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Sarah'**
  String get doctorFacilityNameHint;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any extra details...'**
  String get additionalNotesHint;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @tapToUploadDoc.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload PDF, JPG, or PNG'**
  String get tapToUploadDoc;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @maleLabel.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleLabel;

  /// No description provided for @femaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterAddress;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationsTitle;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when something important happens'**
  String get noNotificationsSubtitle;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmedTitle;

  /// No description provided for @bookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking Information'**
  String get bookingInformation;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @appointmentBooked.
  ///
  /// In en, this message translates to:
  /// **'Appointment Booked'**
  String get appointmentBooked;

  /// No description provided for @getLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Location'**
  String get getLocation;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @cashAtClinicDefault.
  ///
  /// In en, this message translates to:
  /// **'Cash at Clinic'**
  String get cashAtClinicDefault;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
