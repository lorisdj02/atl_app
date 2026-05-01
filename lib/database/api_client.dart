import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Singleton per gestire il client Dio
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  // Callback che ritorna il token corrente (username)
  String? Function()? _tokenProvider;

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

  void setTokenProvider(String? Function() provider) {
    _tokenProvider = provider;
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
          final token = _tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Ottieni l'istanza Dio configurata
  static Dio get instance => _instance.dio;
}
