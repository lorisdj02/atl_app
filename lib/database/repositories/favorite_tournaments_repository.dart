import '../../models/favorite_tournaments.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class FavoriteTournamentsRepository extends BaseRepository<FavoriteTournaments> {
  @override
  String get endpoint => 'favorite_tournaments';

  @override
  FavoriteTournaments fromJson(Map<String, dynamic> json) => FavoriteTournaments.fromJson(json);

  @override
  Map<String, dynamic> toJson(FavoriteTournaments item) => item.toJson();

  List<FavoriteTournaments> _mockData = [
  ];

  @override
  List<FavoriteTournaments> get mockData => _mockData;

  Future<List<FavoriteTournaments>> getByUserId(int userId) async {
    if(AppConfig.isDebug){
      return _mockData.where((fav) => fav.userId == userId).toList();
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> addFavorite(int userId, int tournamentId) async {
    if(AppConfig.isDebug){
      _mockData.add(FavoriteTournaments(
        userId: userId,
        tournamentId: tournamentId,
      ));
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> removeFavorite(int userId, int tournamentId) async {
    if(AppConfig.isDebug){
      _mockData.removeWhere((fav) =>
          fav.userId == userId && fav.tournamentId == tournamentId);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> isFavorite(int userId, int tournamentId) async{
    if(AppConfig.isDebug){
      return _mockData.any(
        (fav) => fav.userId == userId && fav.tournamentId == tournamentId
      );
    }
    else{
      throw UnimplementedError();
    }
  }
}