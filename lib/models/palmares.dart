import 'enums/palmares_position.dart';
// OK
class Palmares {
  final double tournamentId;
  final PalmaresPosition position;

  Palmares({required this.tournamentId, required this.position});

  factory Palmares.fromJson(Map<String, dynamic> json) {
    return Palmares(
      tournamentId: json['tournamentId'] != null ? (json['tournamentId'] as num).toDouble() : 0.0,
      position: PalmaresPositionExtension.fromJson(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId, 'position': position.apiName};
  }
}
