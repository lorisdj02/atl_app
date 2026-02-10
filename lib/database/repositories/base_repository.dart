import 'package:dio/dio.dart';
import '../api_client.dart';

/// Repository base con logica comune per API e mock data
abstract class BaseRepository<T> {
  final Dio _dio = ApiClient.instance;

  /// Espone Dio per query custom nei repository figli
  Dio get dio => _dio;

  /// Nome dell'endpoint API (es: 'users', 'tournaments')
  String get endpoint;

  /// Converte JSON in modello
  T fromJson(Map<String, dynamic> json);

  /// Converte modello in JSON
  Map<String, dynamic> toJson(T item);

  /// Mock data per debug (override nelle sottoclassi)
  List<T> get mockData => [];

  /// Gestione errori Dio centralizzata
  void _handleDioError(DioException e, String action) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('❌ Timeout error while $action');
        break;
      case DioExceptionType.badResponse:
        print('❌ Server error (${e.response?.statusCode}) while $action');
        break;
      case DioExceptionType.connectionError:
        print('❌ Connection error while $action - Check internet connection');
        break;
      case DioExceptionType.cancel:
        print('⚠️ Request cancelled while $action');
        break;
      default:
        print('❌ Unknown error while $action: ${e.message}');
    }
  }
}
