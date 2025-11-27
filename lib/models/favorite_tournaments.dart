

class FavoriteTournaments{
    int userId;
    int tournamentId;

    FavoriteTournaments({
        required this.userId,
        required this.tournamentId,
    });

    factory FavoriteTournaments.fromJson(Map<String, dynamic> json) {
        return FavoriteTournaments(
            userId: json['user_id'],
            tournamentId: json['tournament_id'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'user_id': userId,
            'tournament_id': tournamentId,
        };
    }
}