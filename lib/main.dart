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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          theme: AppTheme.theme,
          // ignore: deprecated_member_use
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
