import 'package:flutter/material.dart';
import '../database/db_controller.dart';
import '../widgets/team_widget.dart';

class TeamRanksScreen extends StatelessWidget {
  const TeamRanksScreen({super.key});

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

            return TeamWidget(
              team: team,
              rankPts: points,
              color: index < 2 ? Colors.green.shade100 : Colors.white,
              imageUrl: team.imageUrl, // TODO: Replace with actual image URL
            );
          },
        );
      },
    );
  }
}
