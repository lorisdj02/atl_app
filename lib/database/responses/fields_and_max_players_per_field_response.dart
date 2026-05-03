import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';

class FieldsAndMaxPlayersPerFieldResponse {
  final List<Field> fields;
  final Map<double, int> maxPlayersPerField;

  FieldsAndMaxPlayersPerFieldResponse({
    required this.fields,
    required this.maxPlayersPerField,
  });

  factory FieldsAndMaxPlayersPerFieldResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<Field> fields = (json[ApiJsonKeys.fields] as List)
        .map((x) => Field.fromJson(x))
        .toList();
    print("Fields parsed: ${fields.length}");

    final Map<double, int> maxPlayersPerField =
        (json[ApiJsonKeys.maxPlayersPerField] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("Max players per field parsed: ${maxPlayersPerField.length}");

    return FieldsAndMaxPlayersPerFieldResponse(
      fields: fields,
      maxPlayersPerField: maxPlayersPerField,
    );
  }
}
