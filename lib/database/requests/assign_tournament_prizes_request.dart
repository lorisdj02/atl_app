import 'package:atl_app/config/api_json_keys.dart';

class AssignTournamentPrizesRequest {
  final double tournamentId;
  final double teamId;
  final Map<double, double> prizePerPlayer;

  AssignTournamentPrizesRequest({
    required this.tournamentId,
    required this.teamId,
    required this.prizePerPlayer,
  });


  Map<String, dynamic> toJson() {
    return {
      ApiJsonKeys.tournamentId: tournamentId,
      ApiJsonKeys.teamId: teamId,
      ApiJsonKeys.prizePerPlayer: prizePerPlayer.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}