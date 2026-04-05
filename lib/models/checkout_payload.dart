class CheckoutPayload {
  final int? tournamentId;
  final int? lobbyId;
  final int? playersPaid;

  final int? ownerPlayerId;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int? maxPlayers;
  final int? playersToFind;

  final int? fieldId;

  CheckoutPayload({
    this.tournamentId,
    this.lobbyId,
    this.playersPaid,
    this.ownerPlayerId,
    this.startTime,
    this.finishTime,
    this.maxPlayers,
    this.playersToFind,
    this.fieldId,
  });

  factory CheckoutPayload.fromJson(Map<String, dynamic> json) {
    return CheckoutPayload(
      tournamentId: json['tournamentId'],
      lobbyId: json['lobbyId'],
      playersPaid: json['playersPaid'],
      ownerPlayerId: json['ownerPlayerId'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      finishTime: json['finishTime'] != null
          ? DateTime.parse(json['finishTime'])
          : null,
      maxPlayers: json['maxPlayers'],
      playersToFind: json['playersToFind'],
      fieldId: json['fieldId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'lobbyId': lobbyId,
      'playersPaid': playersPaid,
      'ownerPlayerId': ownerPlayerId,
      'startTime': startTime?.toIso8601String(),
      'finishTime': finishTime?.toIso8601String(),
      'maxPlayers': maxPlayers,
      'playersToFind': playersToFind,
      'fieldId': fieldId,
    };
  }
}
