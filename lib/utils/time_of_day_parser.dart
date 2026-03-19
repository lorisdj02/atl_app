import 'package:flutter/material.dart';

TimeOfDay timeOfDayFromJson(dynamic v) {
  if (v == null) throw FormatException('Invalid time');
  if (v is String) {
    final parts = v.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  if (v is Map) {
    final hour = v['hour'] ?? v['h'];
    final minute = v['minute'] ?? v['m'];
    return TimeOfDay(
      hour: int.parse(hour.toString()),
      minute: int.parse(minute.toString()),
    );
  }
  throw FormatException('Unsupported time format: $v');
}

extension TimeOfDayJson on TimeOfDay {
  Map<String, int> toJson() => {'hour': hour, 'minute': minute};
  String toTimeString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
