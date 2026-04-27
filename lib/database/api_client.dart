import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Singleton per gestire il client Dio
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Interceptor per logging (solo in debug)
    if (AppConfig.isDebug) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    // Interceptor per auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Aggiungi token auth se disponibile
          if (AppConfig.apiKey.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${AppConfig.apiKey}';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // TODO: Gestisci errori comuni (401, 403, 500, etc.)
          return handler.next(error);
        },
      ),
    );
  }

  /// Ottieni l'istanza Dio configurata
  static Dio get instance => _instance.dio;
}
