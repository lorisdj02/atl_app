class PlayerStats {
  final int playerId;

  int footballMotms;
  int footballGamesPlayed;
  int footballGoals;
  int footballYellowCards;
  int footballRedCards;

  PlayerStats({
    required this.playerId,
    this.footballGamesPlayed = 0,
    this.footballGoals = 0,
    this.footballMotms = 0,
    this.footballYellowCards = 0,
    this.footballRedCards = 0,
  });
}
