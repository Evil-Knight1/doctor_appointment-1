/// Named route constants used by GoRouter throughout the app.
abstract class Routes {
  // ── Auth ──
  static const homeView = 'homeView';
  static const loginView = 'loginView';
  static const signUpView = 'signUpView';
  static const doctorSignUpView = 'doctorSignUpView';

  // ── Home sub-views ──
  static const notificationView = 'notificationView';
  static const findNearbyView = 'findNearbyView';
  static const doctorSpecialityView = 'doctorSpecialityView';
  static const recommendationView = 'recommendationView';
  static const doctorDetailsView = 'doctorDetailsView';

  // ── Booking flow ──
  static const bookingDateView = 'bookingDateView';
  static const bookingPaymentView = 'bookingPaymentView';
  static const bookingSummaryView = 'bookingSummaryView';
  static const bookingConfirmedView = 'bookingConfirmedView';
  static const bookingReviewView = 'bookingReviewView';

  // ── Other ──
  static const root = 'root';
  static const onBoardingView = 'onBoardingView';
  static const favoriteView = 'favoriteView';
  static const calendarView = 'calendarView';
  static const profileView = 'profileView';
  static const editProfileView = 'editProfileView';
  static const chatbotView = 'chatbotView';
  static const chatHistoryView = 'chatHistoryView';
  static const medicalRecordsView = 'medicalRecordsView';
  static const createRecordView = 'createRecordView';
  static const paymentHistoryView = 'paymentHistoryView';
  static const transactionDetailsView = 'transactionDetailsView';
  static const checkoutView = 'checkoutView';
  static const appointmentDetailsView = 'appointmentDetailsView';
  static const doctorRoot = 'doctorRoot';
  static const doctorPendingApprovalView = 'doctorPendingApprovalView';
  static const categoryDetailsView = 'categoryDetailsView';
  static const specialtiesView = 'specialtiesView';
  static const newAppointment = 'newAppointment';
  static const patientDetails = 'patientDetails';
  static const appointmentSuccess = 'appointmentSuccess';
}
