/// Configurazione globale dell'app
class AppConfig {
  static const bool isDebug = true; // TODO: Cambia a false in produzione
  static const String apiBaseUrl =
      'http://10.0.2.2:8081/api/v1'; // TODO: URL API reale
  static const String apiKey = 'YOUR_API_KEY_HERE'; // TODO: Chiave API reale

  // Timeout configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
