// OK
class City {
  final double id;
  final String name;
  final String timeZone;

  City({required this.id, required this.name, this.timeZone = 'Europe/Rome'});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: (json['id'] as num).toDouble(),
      name: json['name'],
      timeZone: json['timeZone'] ?? 'Europe/Rome',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'timeZone': timeZone};
  }
}
