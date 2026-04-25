import 'dart:async';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/utils/responsive/adaptive_layout.dart';
import 'package:doctor_appointment/features/splash/presentation/widgets/splash_desktop.dart';
import 'package:doctor_appointment/features/splash/presentation/widgets/splash_mobile.dart';
import 'package:doctor_appointment/features/splash/presentation/widgets/splash_tablet.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/get_cached_session_usecase.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // 1. Minimum splash time for branding
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Check if user has seen onboarding
    final hasSeenOnboarding = SharedPreferencesHelper.getHasSeenOnboarding();
    if (!hasSeenOnboarding) {
      context.go(AppRouter.kOnBoardingView);
      return;
    }

    // 3. Check for secured session and try to refresh
    final getCachedSession = getIt<GetCachedSessionUseCase>();
    final result = await getCachedSession();

    if (result is Success<AuthResponse?>) {
      final session = result.data;
      if (session != null && session.token.isNotEmpty) {
        // 4. Token exists in secured preferences. The AuthTokenInterceptor will
        // automatically attempt a refresh if the token is expired when a request is made,
        // but to be absolutely sure we're valid on startup, we can just route to root
        // and let the interceptor/repository handle 401s.

        final role = session.role.trim().toLowerCase();
        if (role == 'doctor') {
          if (mounted) context.go(AppRouter.kDoctorRoot);
        } else {
          if (mounted) context.go(AppRouter.kRoot);
        }
        return;
      }
    }

    // 5. No token in secured prefs or failure, go to login
    if (mounted) context.go(AppRouter.kLoginView);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AdaptiveLayout(
        mobile: SplashMobile(),
        tablet: SplashTablet(),
        desktop: SplashDesktop(),
      ),
    );
  }
}
