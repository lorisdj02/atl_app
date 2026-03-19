

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';

class FieldsAndMaxPlayersPerFieldResponse {
  final List<Field> fields;
  final Map<int, int> maxPlayersPerField;

  FieldsAndMaxPlayersPerFieldResponse({
    required this.fields,
    required this.maxPlayersPerField,
  });

  factory FieldsAndMaxPlayersPerFieldResponse.fromJson(Map<String, dynamic> json) {
    return FieldsAndMaxPlayersPerFieldResponse(
      fields: List<Field>.from(json[ApiJsonKeys.fields].map((x) => Field.fromJson(x))),
      maxPlayersPerField: Map<int, int>.from(json[ApiJsonKeys.maxPlayersPerField]),
    );
  }
}
  