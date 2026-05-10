import 'package:device_preview/device_preview.dart';
import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/notification_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/utils/app_theme.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:doctor_appointment/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:doctor_appointment/core/logic/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doctor_appointment/core/logic/locale_cubit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background message if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await loadEnv();
  await SharedPreferencesHelper.init();
  setupServiceLocator();
  await getIt<NotificationService>().init();
  await getIt<LogService>().init();
  await SentryFlutter.init((options) {
    options.dsn =
        'https://6c8cfc852f0c2cd49d7017c1a33b72d3@o4508477044031488.ingest.us.sentry.io/4511279429582848';
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(const DoctorAppointment()));
}

class DoctorAppointment extends StatelessWidget {
  const DoctorAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ThemeCubit>()),
        BlocProvider(create: (context) => getIt<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return ScreenUtilInit(
                designSize: const Size(375, 812),
                splitScreenMode: true,
                builder: (context, child) {
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
                      systemNavigationBarColor: themeMode == ThemeMode.dark ? AppColors.darkBg : AppColors.bg,
                      systemNavigationBarIconBrightness: themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
                    ),
                    child: MaterialApp.router(
                      theme: AppTheme.theme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeMode,
                      locale: locale,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      // ignore: deprecated_member_use
                      useInheritedMediaQuery: true,
                      builder: (context, child) {
                        final appChild = DevicePreview.appBuilder(context, child);
                        return OfflineBuilder(
                          connectivityBuilder: (
                            BuildContext context,
                            List<ConnectivityResult> connectivity,
                            Widget child,
                          ) {
                            final bool connected = !connectivity.contains(ConnectivityResult.none);
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                child,
                                if (!connected)
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top,
                                    left: 0,
                                    right: 0,
                                    child: Material(
                                      color: Colors.red,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'No Internet Connection',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          child: appChild,
                        );
                      },
                      routerConfig: AppRouter.router,
                      debugShowCheckedModeBanner: false,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
