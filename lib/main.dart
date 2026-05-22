import 'package:device_preview/device_preview.dart';
import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/notification_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/theme/app_theme.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:doctor_appointment/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:doctor_appointment/core/logic/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doctor_appointment/core/services/chat_cache_service.dart';
import 'package:doctor_appointment/core/services/app_cache_service.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:doctor_appointment/core/logic/locale_cubit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_paymob/flutter_paymob.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
    '[FCM] _firebaseMessagingBackgroundHandler received a background message!',
  );
  print('[FCM] Background Message Data: ${message.data}');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.handleBackgroundRemoteMessage(message);
  print('[FCM] Background Message handling completed.');
}

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://6c8cfc852f0c2cd49d7017c1a33b72d3@o4508477044031488.ingest.us.sentry.io/4511279429582848';
      options.tracesSampleRate = 1.0;
      // ignore: experimental_member_use
      options.profilesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await loadEnv();
      await SharedPreferencesHelper.init();

      await Hive.initFlutter();
      await ChatCacheService.openBoxes();
      await AppCacheService.openBoxes();

      await FlutterPaymob.instance.initialize(
        apiKey: Env.paymobApiKey,
        integrationID: int.tryParse(Env.paymobIntegrationId) ?? 0,
        walletIntegrationId: int.tryParse(Env.paymobIntegrationId) ?? 0,
        iFrameID: int.tryParse(Env.paymobIframeId) ?? 0,
      );

      setupServiceLocator();
      await getIt<NotificationService>().init();
      await getIt<LogService>().init();
      runApp(const DoctorAppointment());
    },
  );
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
                      statusBarIconBrightness:
                          Theme.of(context).brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                      systemNavigationBarColor: Theme.of(
                        context,
                      ).colorScheme.surface,
                      systemNavigationBarIconBrightness:
                          Theme.of(context).brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                    ),
                    child: MaterialApp.router(
                      theme: AppTheme.theme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeMode,
                      locale: locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      builder: (context, child) {
                        final appChild = DevicePreview.appBuilder(
                          context,
                          child,
                        );
                        final responsiveChild = ResponsiveBreakpoints.builder(
                          child: Builder(
                            builder: (context) {
                              return MaxWidthBox(
                                maxWidth: 1200,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: ResponsiveScaledBox(
                                  width: ResponsiveValue<double>(
                                    context,
                                    defaultValue: 450,
                                    conditionalValues: [
                                      const Condition.equals(
                                        name: MOBILE,
                                        value: 450,
                                      ),
                                      const Condition.between(
                                        start: 800,
                                        end: 1100,
                                        value: 800,
                                      ),
                                      const Condition.largerThan(
                                        name: TABLET,
                                        value: 1000,
                                      ),
                                    ],
                                  ).value,
                                  child: appChild,
                                ),
                              );
                            },
                          ),
                          breakpoints: [
                            const Breakpoint(start: 0, end: 450, name: MOBILE),
                            const Breakpoint(
                              start: 451,
                              end: 800,
                              name: TABLET,
                            ),
                            const Breakpoint(
                              start: 801,
                              end: 1920,
                              name: DESKTOP,
                            ),
                            const Breakpoint(
                              start: 1921,
                              end: double.infinity,
                              name: '4K',
                            ),
                          ],
                        );
                        return OfflineBuilder(
                          connectivityBuilder:
                              (
                                BuildContext context,
                                List<ConnectivityResult> connectivity,
                                Widget child,
                              ) {
                                final bool connected = !connectivity.contains(
                                  ConnectivityResult.none,
                                );
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              'No Internet Connection',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                          child: responsiveChild,
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
