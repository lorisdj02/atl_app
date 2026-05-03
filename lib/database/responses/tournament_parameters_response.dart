

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
      final double fee = (json[ApiJsonKeys.fee] as num).toDouble();
      print("Fee parsed: $fee");

  final double coordinatorPay = (json[ApiJsonKeys.coordinatorPay] as num).toDouble();
      print("Coordinator pay parsed: $coordinatorPay");

  final double? prize1 = json[ApiJsonKeys.prize1] != null ? (json[ApiJsonKeys.prize1] as num).toDouble() : null;
      print("Prize 1 parsed: $prize1");

  final double? prize2 = json[ApiJsonKeys.prize2] != null ? (json[ApiJsonKeys.prize2] as num).toDouble() : null;
      print("Prize 2 parsed: $prize2");

    return TournamentParametersResponse(
      fee: fee,
      coordinatorPay: coordinatorPay,
      prize1: prize1,
      prize2: prize2,
    );
  }
}