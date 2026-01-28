class RefereeRoles {
  final int sportId;
  final String name;
  final int level;
  final double payPerMatch;

  RefereeRoles({
    required this.sportId,
    required this.name,
    required this.level,
    required this.payPerMatch,
  }
  );

  factory RefereeRoles.fromJson(Map<String, dynamic> json) {
    return RefereeRoles(
      sportId: json['sport_id'],
      name: json['name'],
      level: json['level'],
      payPerMatch: json['pay_per_match'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sport_id': sportId,
      'name': name,
      'level': level,
      'pay_per_match': payPerMatch,
    };
  }
}