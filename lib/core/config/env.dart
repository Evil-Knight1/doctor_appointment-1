import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnv() async {
  await dotenv.load(fileName: "assets/envs/.env");
}

abstract class Env {
  static String get apiUrl => dotenv.env["API_URL"] ?? "";
}
