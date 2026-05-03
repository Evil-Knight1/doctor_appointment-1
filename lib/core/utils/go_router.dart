import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/widgets/bottom_navigation_bar.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/appointment_success_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/new_appointment_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/patient_details_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/auth/presentation/views/login_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/signup_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/forgot_password_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/verify_otp_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/reset_password_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/user_selection_view.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/forgot_password_cubit.dart';
import 'package:doctor_appointment/features/calendar/presentation/views/calendar_view.dart';
import 'package:doctor_appointment/features/favorite/presentation/views/favorite_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/home_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/notification_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/find_nearby_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/doctor_speciality_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/recommendation_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/doctor_details_view.dart'
    as home_doctor_details;
import 'package:doctor_appointment/features/home/presentation/views/booking_date_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/booking_payment_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/booking_summary_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/booking_confirmed_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/booking_review_view.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart'
    as home_models;
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/chatbot/presentation/views/chatbot_view.dart';
import 'package:doctor_appointment/features/profile/presentation/views/profile_view.dart';
import 'package:doctor_appointment/features/profile/presentation/views/edit_profile_view.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/splash/presentation/views/splash_view.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/views/on_boarding_view.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/features/auth/presentation/views/doctor_pending_approval_view.dart'
    as doctor_pending;
import 'package:doctor_appointment/features/medical_records/presentation/views/medical_records_view.dart';
import 'package:doctor_appointment/features/medical_records/presentation/views/create_record_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_root.dart';
import 'package:doctor_appointment/features/payments/presentation/views/payment_history_view.dart';
import 'package:doctor_appointment/features/payments/presentation/views/transaction_details_view.dart';
import 'package:doctor_appointment/features/payments/presentation/views/checkout_view.dart';
import 'package:doctor_appointment/features/chatbot/presentation/views/chat_history_view.dart';
import 'package:doctor_appointment/features/chatbot/logic/chat_cubit.dart';
import 'package:doctor_appointment/features/chatbot/logic/chat_history_cubit.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/appointment_details_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/doctor_signup_view.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kUserSelectionView = '/userSelectionView';
  static const kOnBoardingView = '/onBoardingView';
  static const kHomeView = '/homeView';
  static const kSignUpView = '/signUpView';
  static const kRoot = '/root';
  static const kFavoriteView = '/favoriteView';
  static const kCalendarView = '/calendarView';
  static const kProfileView = '/profileView';
  static const kChatbotView = '/chatbotView';
  static const kDoctorDetail = '/doctorDetail';
  static const kNewAppointment = '/newAppointment';
  static const kPatientDetails = '/patientDetails';
  static const kAppointmentSuccess = '/appointmentSuccess';
  static const kAppointmentsView = '/appointmentsView';
  static const kEditProfileView = '/editProfileView';
  static const kDoctorPendingApprovalView = '/doctorPendingApprovalView';
  static const kMedicalRecordsView = '/medicalRecordsView';
  static const kCreateRecordView = '/createRecordView';
  static const kPaymentHistoryView = '/paymentHistoryView';
  static const kTransactionDetailsView = '/transactionDetailsView';
  static const kCheckoutView = '/checkoutView';
  static const kChatHistoryView = '/chatHistoryView';
  static const kAppointmentDetailsView = '/appointmentDetailsView';
  static const kDoctorRoot = '/doctorRoot';
  static const kDoctorSignUpView = '/doctorSignUpView';
  static const kForgotPasswordView = '/forgotPasswordView';
  static const kVerifyOtpView = '/verifyOtpView';
  static const kResetPasswordView = '/resetPasswordView';

  // ── Home sub-routes ──
  static const kNotificationView = '/notificationView';
  static const kFindNearbyView = '/findNearbyView';
  static const kDoctorSpecialityView = '/doctorSpecialityView';
  static const kRecommendationView = '/recommendationView';
  static const kHomeDoctorDetailsView = '/homeDoctorDetailsView';
  static const kBookingDateView = '/bookingDateView';
  static const kBookingPaymentView = '/bookingPaymentView';
  static const kBookingSummaryView = '/bookingSummaryView';
  static const kBookingConfirmedView = '/bookingConfirmedView';
  static const kBookingReviewView = '/bookingReviewView';

  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(
        name: Routes.loginView,
        path: kLoginView,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: kUserSelectionView,
        builder: (context, state) => const UserSelectionView(),
      ),
      GoRoute(
        name: Routes.onBoardingView,
        path: kOnBoardingView,
        builder: (context, state) => const OnBoardingView(),
      ),
      GoRoute(
        name: Routes.homeView,
        path: kHomeView,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        name: Routes.signUpView,
        path: kSignUpView,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const SignUpView(),
        ),
      ),
      GoRoute(
        name: Routes.root,
        path: kRoot,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  getIt<DoctorsCubit>()..fetchDoctors(pageNumber: 1, pageSize: 10, minRating: 3.5),
            ),
            BlocProvider(
              create: (context) => getIt<AppointmentsCubit>()..loadAppointments(),
            ),
            BlocProvider(
              create: (context) => getIt<ProfileCubit>()..loadProfile(),
            ),
          ],
          child: const Root(),
        ),
      ),
      GoRoute(
        name: Routes.favoriteView,
        path: kFavoriteView,
        builder: (context, state) => const FavoriteView(),
      ),
      GoRoute(
        name: Routes.calendarView,
        path: kCalendarView,
        builder: (context, state) => const CalendarView(),
      ),
      GoRoute(
        name: Routes.profileView,
        path: kProfileView,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        name: Routes.editProfileView,
        path: kEditProfileView,
        builder: (context, state) {
          final profile = state.extra as PatientProfile;
          return EditProfileView(profile: profile);
        },
      ),
      GoRoute(
        name: Routes.chatbotView,
        path: kChatbotView,
        builder: (context, state) {
          final sessionId = state.extra as String?;
          return BlocProvider(
            create: (context) => getIt<ChatCubit>()..initChat(sessionId: sessionId),
            child: const ChatbotView(),
          );
        },
      ),
      GoRoute(
        name: Routes.chatHistoryView,
        path: kChatHistoryView,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ChatHistoryCubit>()..fetchUserChats(),
          child: const ChatHistoryView(),
        ),
      ),
      GoRoute(
        name: Routes.doctorPendingApprovalView,
        path: kDoctorPendingApprovalView,
        builder: (context, state) {
          return const doctor_pending.DoctorPendingApprovalView();
        },
      ),
      GoRoute(
        name: Routes.medicalRecordsView,
        path: kMedicalRecordsView,
        builder: (context, state) => const MedicalRecordsView(),
      ),
      GoRoute(
        name: Routes.createRecordView,
        path: kCreateRecordView,
        builder: (context, state) => const CreateRecordView(),
      ),
      GoRoute(
        name: Routes.paymentHistoryView,
        path: kPaymentHistoryView,
        builder: (context, state) => const PaymentHistoryView(),
      ),
      GoRoute(
        name: Routes.transactionDetailsView,
        path: kTransactionDetailsView,
        builder: (context, state) => const TransactionDetailsView(),
      ),
      GoRoute(
        name: Routes.checkoutView,
        path: kCheckoutView,
        builder: (context, state) {
          final payload = state.extra as CheckoutPayload;
          return CheckoutView(payload: payload);
        },
      ),
      GoRoute(
        name: Routes.appointmentDetailsView,
        path: kAppointmentDetailsView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return AppointmentDetailsView(appointmentData: data);
        },
      ),
      GoRoute(
        name: Routes.doctorRoot,
        path: kDoctorRoot,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<DoctorStatsCubit>()..fetchStats(),
            ),
            BlocProvider(
              create: (context) =>
                  getIt<DoctorAppointmentsCubit>()..fetchAppointments(),
            ),
            BlocProvider(
              create: (context) => getIt<DoctorProfileCubit>()..fetchProfile(),
            ),
          ],
          child: const DoctorRoot(),
        ),
      ),
      GoRoute(
        name: Routes.doctorSignUpView,
        path: kDoctorSignUpView,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<AuthCubit>()),
            BlocProvider(
              create: (context) => getIt<SpecializationsCubit>()..fetchSpecializations(),
            ),
          ],
          child: const DoctorSignUpView(),
        ),
      ),
      GoRoute(
        path: kForgotPasswordView,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ForgotPasswordCubit>(),
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: kVerifyOtpView,
        builder: (context, state) {
          final email = state.extra as String;
          return BlocProvider.value(
            value: getIt<ForgotPasswordCubit>(),
            child: VerifyOtpView(email: email),
          );
        },
      ),
      GoRoute(
        path: kResetPasswordView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BlocProvider.value(
            value: getIt<ForgotPasswordCubit>(),
            child: ResetPasswordView(
              email: data['email'] as String,
              token: data['token'] as String,
            ),
          );
        },
      ),

      // ── Existing appointment flow (uses API DoctorModel) ──
      GoRoute(
        name: Routes.newAppointment,
        path: kNewAppointment,
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return NewAppointmentView(doctor: doctor);
        },
      ),
      GoRoute(
        name: Routes.patientDetails,
        path: kPatientDetails,
        builder: (context, state) {
          final draft = state.extra as AppointmentDraft;
          return PatientDetailsView(draft: draft);
        },
      ),
      GoRoute(
        name: Routes.appointmentSuccess,
        path: kAppointmentSuccess,
        builder: (context, state) => const AppointmentSuccessView(),
      ),

      // ── Home sub-view routes ──
      GoRoute(
        name: Routes.notificationView,
        path: kNotificationView,
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        name: Routes.findNearbyView,
        path: kFindNearbyView,
        builder: (context, state) => const FindNearbyView(),
      ),
      GoRoute(
        name: Routes.doctorSpecialityView,
        path: kDoctorSpecialityView,
        builder: (context, state) => const DoctorSpecialityView(),
      ),
      GoRoute(
        name: Routes.recommendationView,
        path: kRecommendationView,
        builder: (context, state) {
          final speciality = state.extra as String?;
          return RecommendationView(filterSpeciality: speciality);
        },
      ),
      GoRoute(
        name: Routes.doctorDetailsView,
        path: kHomeDoctorDetailsView,
        builder: (context, state) {
          final doctor = state.extra as home_models.DoctorModel;
          return home_doctor_details.DoctorDetailView(doctor: doctor);
        },
      ),
      GoRoute(
        name: Routes.bookingDateView,
        path: kBookingDateView,
        builder: (context, state) {
          final doctor = state.extra as home_models.DoctorModel;
          return BookingDateView(doctor: doctor);
        },
      ),
      GoRoute(
        name: Routes.bookingPaymentView,
        path: kBookingPaymentView,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BookingPaymentView(args: args);
        },
      ),
      GoRoute(
        name: Routes.bookingSummaryView,
        path: kBookingSummaryView,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BookingSummaryView(args: args);
        },
      ),
      GoRoute(
        name: Routes.bookingConfirmedView,
        path: kBookingConfirmedView,
        builder: (context, state) => const BookingConfirmedView(),
      ),
      GoRoute(
        name: Routes.bookingReviewView,
        path: kBookingReviewView,
        builder: (context, state) {
          final doctor = state.extra as home_models.DoctorModel;
          return BookingReviewView(doctor: doctor);
        },
      ),
    ],
  );
}
