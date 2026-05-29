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
