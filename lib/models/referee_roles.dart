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
      sportId: json['sportId'],
      name: json['name'],
      level: json['level'],
      payPerMatch: json['payPerMatch'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sportId': sportId,
      'name': name,
      'level': level,
      'payPerMatch': payPerMatch,
    };
  }
}