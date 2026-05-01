import 'package:dio/dio.dart';

class FieldServiceWrite {
  final String apiUrl;
  final Dio dio;

  FieldServiceWrite({
    required this.apiUrl,
    required this.dio,
  });

}