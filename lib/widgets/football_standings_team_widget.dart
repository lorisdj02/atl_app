import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import 'abstract_team_widget.dart';

/// Widget per visualizzare un team nella classifica
///
/// TODO: Ordinamento standings (gestito nel DB):
/// I team vengono ordinati in base al campo 'rank' salvato nel DB.
/// Il rank viene calcolato dal backend secondo questi criteri:
/// 1. Punti (points) - DESC
/// 2. Goal Difference (goalsScored - goalsConceded) - DESC
/// 3. Goal Scored (goalsScored) - DESC
/// 4. Goal Conceded (goalsConceded) - ASC
/// 5. Nome team (team.name) - ASC (alfabetico)
///
/// L'ordinamento avviene sempre all'interno dello stesso gruppo.
/// Il frontend si fida ciecamente del valore 'rank' fornito dal DB.
class FootballStandingsTeamWidget extends AbstractTeamWidget {
  final Color color;
  final int? rank;
  final String? standingRecord;
  final int? goalDifference;

  const FootballStandingsTeamWidget({
    super.key,
    required super.team,
    this.color = Colors.white,
    super.imageUrl,
    this.rank,
    this.standingRecord,
    this.goalDifference,
    required super.sportCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleTeamTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 30,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color == Colors.white
                      ? ATLColors.darkBlue
                      : Colors.white,
                ),
              ),
            ),
            // Logo
            buildTeamLogo(size: 40),
            const SizedBox(width: 12),
            // Team name
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color == Colors.white ? Colors.black : Colors.white,
                ),
              ),
            ),
            // Full record (Pts - W - D - L - GD)
            if (standingRecord != null)
              Text(
                standingRecord!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color == Colors.white
                      ? ATLColors.darkBlue
                      : Colors.white,
                ),
              ),
            if (goalDifference != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  ' - ${goalDifference! >= 0 ? '+' : ''}$goalDifference',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color == Colors.white
                        ? ATLColors.darkBlue
                        : Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
