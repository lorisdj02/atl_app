import 'package:dio/dio.dart';
import '../../config/app_config.dart';
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


  /// GET - Ottieni tutti gli elementi
  Future<List<T>> getAll() async {
    if (AppConfig.isDebug) {
      // Simula delay di rete
      await Future.delayed(const Duration(milliseconds: 500));
      return mockData;
    } else {
      return _apiGetAll();
    }
  }

  /// GET - Ottieni elemento per ID
  Future<T?> getById(int id) async {
    if (AppConfig.isDebug) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return mockData.firstWhere((item) {
          final json = toJson(item);
          return json['id'] == id;
        });
      } catch (e) {
        return null;
      }
    } else {
      return _apiGetById(id);
    }
  }

  /// POST - Crea nuovo elemento
  Future<T> create(T item) async {
    if (AppConfig.isDebug) {
      await Future.delayed(const Duration(milliseconds: 400));
      // In mock, ritorna l'elemento stesso
      print('🔧 [DEBUG] Created $endpoint: ${toJson(item)}');
      return item;
    } else {
      return _apiCreate(item);
    }
  }

  /// PUT - Aggiorna elemento esistente
  Future<T> update(int id, T item) async {
    if (AppConfig.isDebug) {
      await Future.delayed(const Duration(milliseconds: 400));
      print('🔧 [DEBUG] Updated $endpoint #$id: ${toJson(item)}');
      return item;
    } else {
      return _apiUpdate(id, item);
    }
  }

  /// DELETE - Elimina elemento
  Future<bool> delete(T item) async {
    if (AppConfig.isDebug) {
      await Future.delayed(const Duration(milliseconds: 300));
      //print('🔧 [DEBUG] Deleted $endpoint #$id');
      return true;
    } else {
      return _apiDelete(toJson(item)['id'] as int);
    }
  }

  // API Methods (produzione) con Dio

  Future<List<T>> _apiGetAll() async {
    try {
      final response = await _dio.get('/$endpoint');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format for $endpoint');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'fetching $endpoint');
      rethrow;
    }
  }

  Future<T?> _apiGetById(int id) async {
    try {
      final response = await _dio.get('/$endpoint/$id');
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      _handleDioError(e, 'fetching $endpoint #$id');
      rethrow;
    }
  }

  Future<T> _apiCreate(T item) async {
    try {
      final response = await _dio.post(
        '/$endpoint',
        data: toJson(item),
      );
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e, 'creating $endpoint');
      rethrow;
    }
  }

  Future<T> _apiUpdate(int id, T item) async {
    try {
      final response = await _dio.put(
        '/$endpoint/$id',
        data: toJson(item),
      );
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e, 'updating $endpoint #$id');
      rethrow;
    }
  }

  Future<bool> _apiDelete(int id) async {
    try {
      await _dio.delete('/$endpoint/$id');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 200 || e.response?.statusCode == 204) {
        return true;
      }
      _handleDioError(e, 'deleting $endpoint #$id');
      return false;
    }
  }

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
