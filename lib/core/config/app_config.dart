class AppConfig {
  final String apiUrl;

  AppConfig({required this.apiUrl});
  void validate() {
    if (apiUrl.isEmpty) {
      throw Exception("API_URL is not defined");
    }
  }
}
