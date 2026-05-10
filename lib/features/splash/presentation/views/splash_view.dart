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
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:doctor_appointment/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';

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

    if (!mounted) return;

    // 2. Check if user has seen onboarding
    final hasSeenOnboarding = SharedPreferencesHelper.getHasSeenOnboarding();
    if (!hasSeenOnboarding) {
      context.go(AppRouter.kOnBoardingView);
      return;
    }

    // 3. Check for secured session
    final getCachedSession = getIt<GetCachedSessionUseCase>();
    final result = await getCachedSession();

    if (result is Success<AuthResponse?>) {
      AuthResponse? session = result.data;
      if (session != null && session.token.isNotEmpty) {
        // 4. Proactive Token Refresh Check
        // Check if the JWT token is already expired
        if (JwtDecoder.isExpired(session.token)) {
          final refreshTokenUseCase = getIt<RefreshTokenUseCase>();
          final refreshResult = await refreshTokenUseCase(
            RefreshTokenParams(
                token: session.token, refreshToken: session.refreshToken),
          );

          if (refreshResult is Success<AuthResponse>) {
            session = refreshResult.data;
            // Update the locally cached session
            final localDataSource = getIt<AuthLocalDataSource>();
            await localDataSource.cacheAuthSession(session);
          } else {
            // Refresh token failed/expired -> force re-login
            if (mounted) context.go(AppRouter.kLoginView);
            return;
          }
        }

        final role = session.role.trim().toLowerCase();
        if (role == 'doctor') {
          if (mounted) context.go(AppRouter.kDoctorRoot);
        } else {
          if (mounted) context.go(AppRouter.kRoot);
        }
        return;
      }
    }

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
