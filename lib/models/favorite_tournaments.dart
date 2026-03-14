class FavoriteTournaments {
  int userId;
  int tournamentId;

  FavoriteTournaments({required this.userId, required this.tournamentId});

  factory FavoriteTournaments.fromJson(Map<String, dynamic> json) {
    return FavoriteTournaments(
      userId: json['userId'],
      tournamentId: json['tournamentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'tournamentId': tournamentId};
  }
}
