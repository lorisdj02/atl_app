class LobbyBookingParticipation {
  final int playerId;
  final int lobbyBookingId;
  final int playersPaid;
  final DateTime joinedAt;

  LobbyBookingParticipation({
    required this.playerId,
    required this.lobbyBookingId,
    required this.joinedAt,
    this.playersPaid = 1,
  });

  factory LobbyBookingParticipation.fromJson(Map<String, dynamic> json) {
    return LobbyBookingParticipation(
      playerId: json['playerId'],
      lobbyBookingId: json['lobbyBookingId'],
      joinedAt: DateTime.parse(json['joinedAt']),
      playersPaid: json['playersPaid'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'lobbyBookingId': lobbyBookingId,
      'joinedAt': joinedAt.toIso8601String(),
      'playersPaid': playersPaid,
    };
  }
}
