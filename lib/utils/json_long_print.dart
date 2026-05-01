import 'dart:convert';
import 'package:flutter/foundation.dart';

class JsonLongPrint {
  static void printLongJson(Object? json) {
    final text = const JsonEncoder.withIndent('  ').convert(json);
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      debugPrint(text.substring(i, end));
    }
  }
}
