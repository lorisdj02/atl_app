import 'package:flutter/material.dart';
import '../database/db_controller.dart';
import '../widgets/ranks_team_widget.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';

class TeamRanksScreen extends StatelessWidget {
  final SportCategory sportCategory;

  const TeamRanksScreen({super.key, required this.sportCategory});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DB.Teams.getAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final teams = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            final points = team.rankPts ?? 0;

            return RanksTeamWidget(
              team: team,
              rankPts: points,
              color: index == 0 ? ATLColors.getPrimaryColor(sportCategory)
                     : index == 1 ? ATLColors.getSecondaryColor(sportCategory)
                     : Colors.white,
              sportCategory: sportCategory,
              imageUrl: team.imageUrl, // TODO: Replace with actual image URL
            );
          },
        );
      },
    );
  }
}
