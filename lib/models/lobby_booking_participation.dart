class LobbyBookingParticipation {
  final int playerId;
  final int lobbyBookingId;
  final DateTime joinedAt;

  LobbyBookingParticipation({
    required this.playerId,
    required this.lobbyBookingId,
    required this.joinedAt,
  });

  factory LobbyBookingParticipation.fromJson(Map<String, dynamic> json) {
    return LobbyBookingParticipation(
      playerId: json['playerId'],
      lobbyBookingId: json['lobbyBookingId'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'lobbyBookingId': lobbyBookingId,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}