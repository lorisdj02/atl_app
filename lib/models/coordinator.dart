/// Modello Coordinator dal database
/// OK
class Coordinator {
  final double coordinatorId;
  final String name;
  final String surname;
  final double accountId;
  final String username;
  final String? imageUrl;
  final double? preferredCityId;
  final int level;

  Coordinator({
    required this.accountId,
    required this.coordinatorId,
    required this.level,
    required this.name,
    required this.surname,
    required this.username,
    required this.imageUrl,
    required this.preferredCityId,
  });

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      accountId: (json['accountId'] as num).toDouble(),
      coordinatorId: (json['coordinatorId'] as num).toDouble(),
      level: (json['level'] as num).toInt(),
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      imageUrl: json['imageUrl'],
      preferredCityId: (json['preferredCityId'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'coordinatorId': coordinatorId,
      'username': username,
      'imageUrl': imageUrl,
      'name': name,
      'surname': surname,
      'level': level,
    };
  }

  String get fullName => '$name $surname';

  /// Descrizione livello coordinatore
  String get levelDescription {
    switch (level) {
      case 1:
        return 'Junior Coordinator';
      case 2:
        return 'Senior Coordinator';
      case 3:
        return 'Expert Coordinator';
      default:
        return 'Level $level';
    }
  }
}
