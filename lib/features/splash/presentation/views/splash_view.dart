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
    if (!mounted) return;

    // 1. Onboarding gate
    final hasSeenOnboarding = SharedPreferencesHelper.getHasSeenOnboarding();
    if (!hasSeenOnboarding) {
      context.go(AppRouter.kOnBoardingView);
      return;
    }

    // 2. Load stored session
    final getCachedSession = getIt<GetCachedSessionUseCase>();
    final result = await getCachedSession();

    if (result is! Success<AuthResponse?>) {
      if (mounted) context.go(AppRouter.kLoginView);
      return;
    }

    final session = result.data;
    if (session == null || session.token.isEmpty) {
      if (mounted) context.go(AppRouter.kLoginView);
      return;
    }

    // 3. Always attempt a proactive refresh on startup so the new token is
    //    ready before any screen makes its first API call.
    //    - If the refresh token itself has expired the server will 401 →
    //      we catch that and redirect to login.
    //    - If the server is unreachable we fall back to the cached token and
    //      let the interceptor handle any subsequent 401.
    AuthResponse freshSession = session;
    final refreshTokenUseCase = getIt<RefreshTokenUseCase>();
    final refreshResult = await refreshTokenUseCase(
      RefreshTokenParams(
        token: session.token,
        refreshToken: session.refreshToken,
      ),
    );

    if (refreshResult is Success<AuthResponse>) {
      freshSession = refreshResult.data;
      // Persist to both stores so the interceptor always reads a fresh token.
      final localDataSource = getIt<AuthLocalDataSource>();
      await localDataSource.cacheAuthSession(freshSession);
      await SharedPreferencesHelper.saveToken(freshSession.token);
    } else if (JwtDecoder.isExpired(session.token)) {
      // Refresh failed AND the local token is already expired → force login.
      if (mounted) context.go(AppRouter.kLoginView);
      return;
    }
    // If refresh failed but the cached token is still valid, proceed anyway.

    // 4. Route by role
    final role = freshSession.role.trim().toLowerCase();
    if (mounted) {
      context.go(role == 'doctor' ? AppRouter.kDoctorRoot : AppRouter.kRoot);
    }
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
