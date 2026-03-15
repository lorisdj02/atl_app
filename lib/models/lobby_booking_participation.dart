class LobbyBookingParticipation {
  final int id;
  final int playerId;
  final int lobbyBookingId;
  final int playersPaid;
  final DateTime joinedAt;
  final double price;
  bool isRefound;

  LobbyBookingParticipation({
    required this.id,
    required this.playerId,
    required this.lobbyBookingId,
    required this.joinedAt,
    this.playersPaid = 1,
    required this.price,
    this.isRefound = false,
  });

  factory LobbyBookingParticipation.fromJson(Map<String, dynamic> json) {
    return LobbyBookingParticipation(
      id: json['id'],
      playerId: json['playerId'],
      lobbyBookingId: json['lobbyBookingId'],
      joinedAt: DateTime.parse(json['joinedAt']),
      playersPaid: json['playersPaid'] ?? 1,
      price: json['price']?.toDouble() ?? 0.0,
      isRefound: json['isRefound'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'lobbyBookingId': lobbyBookingId,
      'joinedAt': joinedAt.toIso8601String(),
      'playersPaid': playersPaid,
      'price': price,
      'isRefound': isRefound,
    };
  }
}
