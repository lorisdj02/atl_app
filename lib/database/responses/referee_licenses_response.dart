import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/referee_license.dart';
import 'package:atl_app/models/sport.dart';

class RefereeLicensesResponse{
  final List<RefereeLicense> refereeLicenses;
  final List<Sport> sports;

  RefereeLicensesResponse({
    required this.refereeLicenses,
    required this.sports,
  });

  factory RefereeLicensesResponse.fromJson(Map<String, dynamic> json) {
    return RefereeLicensesResponse(
      refereeLicenses: List<RefereeLicense>.from(json[ApiJsonKeys.refereeLicenses].map((x) => RefereeLicense.fromJson(x))),
      sports: List<Sport>.from(json[ApiJsonKeys.sports].map((x) => Sport.fromJson(x))),
    );
  }
}