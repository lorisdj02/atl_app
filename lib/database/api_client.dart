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
          error: false,
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
        onError: (error, handler) {
          final statusCode = error.response?.statusCode;
          final responseText = error.response?.data?.toString();
          if (statusCode != null) {
            throw Exception(
              _formatStatusMessage(statusCode, responseText),
            );
          }
          throw Exception('NETWORK_ERROR');
        },
      ),
    );
  }

  String _formatStatusMessage(int statusCode, String? textStatus) {
    final trimmed = textStatus?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return '$statusCode $trimmed';
    }
    return '$statusCode ${_statusLabel(statusCode)}';
  }

  String _statusLabel(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        return 'AUTHENTICATION';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 422:
        return 'VALIDATION';
      case 500:
        return 'SERVER_ERROR';
      default:
        return 'HTTP_ERROR';
    }
  }

  /// Ottieni l'istanza Dio configurata
  static Dio get instance => _instance.dio;
}
