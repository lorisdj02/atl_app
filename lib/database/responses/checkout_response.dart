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
  final int? totalPlayers;
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
    required this.totalPlayers,
    required this.playersToPay,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    final CheckoutSession checkoutSession = CheckoutSession.fromJson(
      json[ApiJsonKeys.checkoutSession] as Map<String, dynamic>,
    );
    print("Checkout session parsed: ${checkoutSession.id}");

    final Wallet wallet = Wallet.fromJson(
      json[ApiJsonKeys.wallet] as Map<String, dynamic>,
    );
    print("Wallet parsed: ${wallet.id}");

    final String? tournamentName = json[ApiJsonKeys.tournamentName] != null
        ? json[ApiJsonKeys.tournamentName] as String
        : null;
    print("Tournament name parsed: $tournamentName");

    final String? bookingUsername = json[ApiJsonKeys.bookingUsername] != null
        ? json[ApiJsonKeys.bookingUsername] as String
        : null;
    print("Booking username parsed: $bookingUsername");

    final String? cityName = json[ApiJsonKeys.cityName] != null
        ? json[ApiJsonKeys.cityName] as String
        : null;
    print("City name parsed: $cityName");

    final String? fieldName = json[ApiJsonKeys.fieldName] != null
        ? json[ApiJsonKeys.fieldName] as String
        : null;
    print("Field name parsed: $fieldName");

    final String? fieldAddress = json[ApiJsonKeys.fieldAddress] != null
        ? json[ApiJsonKeys.fieldAddress] as String
        : null;
    print("Field address parsed: $fieldAddress");

    final DateTime? startTime = json[ApiJsonKeys.startTime] != null
        ? DateTime.parse(json[ApiJsonKeys.startTime] as String)
        : null;
    print("Start time parsed: $startTime");

    final DateTime? finishTime = json[ApiJsonKeys.finishTime] != null
        ? DateTime.parse(json[ApiJsonKeys.finishTime] as String)
        : null;
    print("Finish time parsed: $finishTime");

    final int? totalPlayers = (json[ApiJsonKeys.totalPlayers] as num?)?.toInt();
    print("Total players parsed: $totalPlayers");

    final int? playersToPay = (json[ApiJsonKeys.playersToPay] as num?)?.toInt();
    print("Players to pay parsed: $playersToPay");

    return CheckoutResponse(
      checkoutSession: checkoutSession,
      wallet: wallet,
      tournamentName: tournamentName,
      bookingUsername: bookingUsername,
      cityName: cityName,
      fieldName: fieldName,
      fieldAddress: fieldAddress,
      startTime: startTime,
      finishTime: finishTime,
      totalPlayers: totalPlayers,
      playersToPay: playersToPay,
    );
  }
}
