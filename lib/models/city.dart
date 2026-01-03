class City {
  final int id;
  final String name;
  final double centerLat;
  final double centerLng;

  City({
    required this.id,
    required this.name,
    required this.centerLat,
    required this.centerLng,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      centerLat: double.parse(json['center_lat'].toString()),
      centerLng: double.parse(json['center_lng'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center_lat': centerLat,
      'center_lng': centerLng,
    };
  }
}
