

import 'package:atl_app/config/api_json_keys.dart';

class TournamentParametersResponse {
  final double fee;
  final double coordinatorPay;
  final double? prize1;
  final double? prize2;
  // final int numMatches;

  TournamentParametersResponse({
    required this.fee,
    required this.coordinatorPay,
    required this.prize1,
    required this.prize2,
  });

  factory TournamentParametersResponse.fromJson(Map<String, dynamic> json) {
    return TournamentParametersResponse(
      fee: json[ApiJsonKeys.fee] as double,
      coordinatorPay: json[ApiJsonKeys.coordinatorPay] as double,
      prize1: json[ApiJsonKeys.prize1] != null ? json[ApiJsonKeys.prize1] as double : null,
      prize2: json[ApiJsonKeys.prize2] != null ? json[ApiJsonKeys.prize2] as double : null,
    );
  }
}