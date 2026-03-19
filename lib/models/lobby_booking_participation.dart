class LobbyBookingParticipation {
  final int id;
  final int playerId;
  final int lobbyBookingId;
  final int playersPaid;
  final DateTime joinedAt;
  final double cost;
  bool isRefund;

  LobbyBookingParticipation({
    required this.id,
    required this.playerId,
    required this.lobbyBookingId,
    required this.joinedAt,
    this.playersPaid = 1,
    required this.cost,
    this.isRefund = false,
  });

  factory LobbyBookingParticipation.fromJson(Map<String, dynamic> json) {
    return LobbyBookingParticipation(
      id: json['id'],
      playerId: json['playerId'],
      lobbyBookingId: json['lobbyBookingId'],
      joinedAt: DateTime.parse(json['joinedAt']),
      playersPaid: json['playersPaid'] ?? 1,
      cost: json['cost']?.toDouble() ?? 0.0,
      isRefund: json['isRefund'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'lobbyBookingId': lobbyBookingId,
      'joinedAt': joinedAt.toIso8601String(),
      'playersPaid': playersPaid,
      'cost': cost,
      'isRefund': isRefund,
    };
  }
}
