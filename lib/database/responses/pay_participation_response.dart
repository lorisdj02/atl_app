
import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';

class PayParticipationResponse {
  final Map<int, Tournament> tournamentsCache;
  final List<TournamentParticipation> tournamentParticipations;
  final Map<int, bool> isCalledUpPerTournament;
  
  PayParticipationResponse({
    required this.tournamentsCache,
    required this.tournamentParticipations,
    required this.isCalledUpPerTournament,
  });

  factory PayParticipationResponse.fromJson(Map<String, dynamic> json) {
    return PayParticipationResponse(
      tournamentsCache: Map<int, Tournament>.from(json[ApiJsonKeys.tournamentsCache]),
      tournamentParticipations: List<TournamentParticipation>.from(json[ApiJsonKeys.tournamentParticipations]),
      isCalledUpPerTournament: Map<int, bool>.from(json[ApiJsonKeys.isCalledUpPerTournament]),
    );
  }
}
