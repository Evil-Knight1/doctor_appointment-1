import 'package:doctor_appointment/core/widgets/bottom_navigation_bar.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/appointment_success_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/new_appointment_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/views/patient_details_view.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/auth/presentation/views/login_view.dart';
import 'package:doctor_appointment/features/auth/presentation/views/signup_view.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/calendar/presentation/views/calendar_view.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/views/doctor_details_view.dart';
import 'package:doctor_appointment/features/favorite/presentation/views/favorite_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/category_detail_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/home_view.dart';
import 'package:doctor_appointment/features/home/presentation/views/specialties_view.dart';
import 'package:doctor_appointment/features/chatbot/presentation/views/chatbot_view.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/profile/presentation/views/profile_view.dart';
import 'package:doctor_appointment/features/profile/presentation/views/edit_profile_view.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/splash/presentation/views/splash_view.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/views/on_boarding_view.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kOnBoardingView = '/onBoardingView';
  static const kHomeView = '/homeView';
  static const kSignUpView = '/signUpView';
  static const kRoot = '/root';
  static const kFavoriteView = '/favoriteView';
  static const kCalendarView = '/calendarView';
  static const kProfileView = '/profileView';
  static const kCategoryDetailsView = '/categoryDetailsView';
  static const kSpecialtiesView = '/specialtiesView';
  static const kChatbotView = '/chatbotView';
  static const kDoctorDetail = '/doctorDetail';
  static const kNewAppointment = '/newAppointment';
  static const kPatientDetails = '/patientDetails';
  static const kAppointmentSuccess = '/appointmentSuccess';
  static const kAppointmentsView = '/appointmentsView';
  static const kEditProfileView = '/editProfileView';

  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(
        path: kLoginView,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: kOnBoardingView,
        builder: (context, state) => const OnBoardingView(),
      ),
      GoRoute(path: kHomeView, builder: (context, state) => const HomeView()),
      GoRoute(
        path: kSignUpView,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const SignUpView(),
        ),
      ),
      GoRoute(path: kRoot, builder: (context, state) => const Root()),
      GoRoute(
        path: kFavoriteView,
        builder: (context, state) => const FavoriteView(),
      ),
      GoRoute(
        path: kCalendarView,
        builder: (context, state) => const CalendarView(),
      ),
      GoRoute(
        path: kProfileView,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: kEditProfileView,
        builder: (context, state) {
          final profile = state.extra as PatientProfile;
          return EditProfileView(profile: profile);
        },
      ),
      GoRoute(
        path: kCategoryDetailsView,
        builder: (context, state) {
          final name = state.extra as String? ?? 'Category';
          return CategoryDetailView(categoryName: name);
        },
      ),
      GoRoute(
        path: kSpecialtiesView,
        builder: (context, state) => const SpecialtiesView(),
      ),
      GoRoute(
        path: kChatbotView,
        builder: (context, state) => const ChatbotView(),
      ),
      GoRoute(
        path: kDoctorDetail,
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return DoctorDetailsView(doctor: doctor);
        },
      ),
      GoRoute(
        path: kNewAppointment,
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return NewAppointmentView(doctor: doctor);
        },
      ),
      GoRoute(
        path: kPatientDetails,
        builder: (context, state) {
          final draft = state.extra as AppointmentDraft;
          return PatientDetailsView(draft: draft);
        },
      ),
      GoRoute(
        path: kAppointmentSuccess,
        builder: (context, state) => const AppointmentSuccessView(),
      ),
    ],
  );
}
