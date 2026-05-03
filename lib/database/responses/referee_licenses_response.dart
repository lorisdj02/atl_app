import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/referee_license.dart';
import 'package:atl_app/models/sport.dart';

class RefereeLicensesResponse {
  final List<RefereeLicense> refereeLicenses;
  final List<Sport> sports;

  RefereeLicensesResponse({
    required this.refereeLicenses,
    required this.sports,
  });

  factory RefereeLicensesResponse.fromJson(Map<String, dynamic> json) {
    final List<RefereeLicense> refereeLicenses =
        (json[ApiJsonKeys.refereeLicenses] as List)
            .map((x) => RefereeLicense.fromJson(x as Map<String, dynamic>))
            .toList();
    print("Referee licenses deserialized: ${refereeLicenses.length}");

    final List<Sport> sports = (json[ApiJsonKeys.sports] as List)
        .map((x) => Sport.fromJson(x as Map<String, dynamic>))
        .toList();
    print("Sports deserialized: ${sports.length}");

    return RefereeLicensesResponse(
      refereeLicenses: refereeLicenses,
      sports: sports,
    );
  }
}
