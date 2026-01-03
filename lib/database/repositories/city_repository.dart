import 'base_repository.dart';
import '../../models/city.dart';
import '../../config/app_config.dart';

class CityRepository extends BaseRepository<City> {
  @override
  String get endpoint => 'cities';

  @override
  City fromJson(Map<String, dynamic> json) => City.fromJson(json);

  @override
  Map<String, dynamic> toJson(City item) => item.toJson();

  List<City> _mockData = [
    City(id: 1, name: 'Milano', centerLat: 45.4642, centerLng: 9.1900),
    City(id: 2, name: 'Roma', centerLat: 41.9028, centerLng: 12.4964),
    City(id: 3, name: 'Taranto', centerLat: 40.4644, centerLng: 17.2470),
  ];

  @override
  List<City> get mockData => _mockData;

  Future<List<City>> getAll() async {
    if (AppConfig.isDebug) {
      return _mockData;
    } else {
      throw UnimplementedError();
    }
  }

  Future<City?> getById(int id) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((city) => city.id == id);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<City?> getByName(String name) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere(
          (city) => city.name.toLowerCase() == name.toLowerCase(),
        );
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }
}
