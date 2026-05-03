import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';

class PayParticipationResponse {
  final Map<double, Tournament> tournamentsCache;
  final List<TournamentParticipation> tournamentParticipations;
  final Map<double, bool> isCalledUpPerTournament;

  PayParticipationResponse({
    required this.tournamentsCache,
    required this.tournamentParticipations,
    required this.isCalledUpPerTournament,
  });

  factory PayParticipationResponse.fromJson(Map<String, dynamic> json) {
    List<TournamentParticipation> tournamentParticipations =
        (json[ApiJsonKeys.tournamentParticipations] as List)
            .map((e) => TournamentParticipation.fromJson(e))
            .toList();
    print(
      "Tournament participations parsed: ${tournamentParticipations.length}",
    );

    Map<double, Tournament> tournamentsCache =
        (json[ApiJsonKeys.tournamentsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), Tournament.fromJson(value)),
        );
    print("Tournaments parsed: ${tournamentsCache.values.length}");

    Map<double, bool> isCalledUpPerTournament =
        (json[ApiJsonKeys.isCalledUpPerTournament] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value as bool),
        );
    print(
      "Is called up per tournament parsed: ${isCalledUpPerTournament.values.length}",
    );

    return PayParticipationResponse(
      tournamentsCache: tournamentsCache,
      tournamentParticipations: tournamentParticipations,
      isCalledUpPerTournament: isCalledUpPerTournament,
    );
  }
}
