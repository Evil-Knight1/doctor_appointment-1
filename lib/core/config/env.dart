import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnv() async {
  await dotenv.load(fileName: "assets/envs/.env");
}

abstract class Env {
  static String get apiUrl => dotenv.env["API_URL"] ?? "";
  static String get paymobApiKey => dotenv.env["PAYMOB_API_KEY"] ?? "";
  static String get paymobIntegrationId => dotenv.env["PAYMOB_INTEGRATION_ID"] ?? "";
  static String get paymobIframeId => dotenv.env["PAYMOB_IFRAME_ID"] ?? "";
}
