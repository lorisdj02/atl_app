import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/wallet.dart';

class CheckoutResponse {
  final CheckoutSession checkoutSession;
  final Wallet wallet;
  final String? tournamentName;
  final String? bookingUsername;
  final String? cityName;
  final String? fieldName;
  final String? fieldAddress;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int? maxPlayers;
  final int? playersToPay;

  CheckoutResponse({
    required this.checkoutSession,
    required this.wallet,
    required this.tournamentName,
    required this.bookingUsername,
    required this.cityName,
    required this.fieldName,
    required this.fieldAddress,
    required this.startTime,
    required this.finishTime,
    required this.maxPlayers,
    required this.playersToPay,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      checkoutSession: CheckoutSession.fromJson(json[ApiJsonKeys.checkoutSession]),
      wallet: Wallet.fromJson(json[ApiJsonKeys.wallet]),
      tournamentName: json[ApiJsonKeys.tournamentName] != null
          ? json[ApiJsonKeys.tournamentName] as String
          : null,
      bookingUsername: json[ApiJsonKeys.bookingUsername] != null
          ? json[ApiJsonKeys.bookingUsername] as String
          : null,
      cityName: json[ApiJsonKeys.cityName] != null
          ? json[ApiJsonKeys.cityName] as String
          : null,
      fieldName: json[ApiJsonKeys.fieldName] != null
          ? json[ApiJsonKeys.fieldName] as String
          : null,
      fieldAddress: json[ApiJsonKeys.fieldAddress] != null
          ? json[ApiJsonKeys.fieldAddress] as String
          : null,
      startTime: json[ApiJsonKeys.startTime] != null
          ? DateTime.parse(json[ApiJsonKeys.startTime] as String)
          : null,
      finishTime: json[ApiJsonKeys.finishTime] != null
          ? DateTime.parse(json[ApiJsonKeys.finishTime] as String)
          : null,
      maxPlayers: json[ApiJsonKeys.maxPlayers] != null
          ? json[ApiJsonKeys.maxPlayers] as int
          : null,
      playersToPay: json[ApiJsonKeys.playersToPay] != null
          ? json[ApiJsonKeys.playersToPay] as int
          : null,
    );
  }
}
