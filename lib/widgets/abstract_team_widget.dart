import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import '../providers/user_provider.dart';
import '../screens/player/my_team_screen.dart';
import '../screens/teams/team_detail_screen.dart';

/// Abstract base widget for all team widgets
/// Provides common functionality like navigation handling
abstract class AbstractTeamWidget extends StatelessWidget {
  final Team team;
  final SportCategory sportCategory;
  final String? imageUrl;

  const AbstractTeamWidget({
    super.key,
    required this.team,
    required this.sportCategory,
    this.imageUrl,
  });

  /// Handles team tap navigation
  /// Checks if player is part of the team and navigates accordingly
  Future<void> handleTeamTap(BuildContext context) async {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (userProvider.isPlayer && userProvider.activeRoleId != null) {
      final int? teamId = userProvider.currentTeamId;


      if (!context.mounted) return;

      if (teamId == null || teamId != team.id) {
        // Player is NOT part of the team -> go to TeamDetailScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TeamDetailScreen(teamId: team.id, currentSport: sportCategory),
          ),
        );
      } else {
        // Player IS part of the team -> go to MyTeamScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MyTeamScreen(currentSport: sportCategory),
          ),
        );
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TeamDetailScreen(teamId: team.id, currentSport: sportCategory),
        ),
      );
    }
  }

  /// Builds the team logo widget
  Widget buildTeamLogo({required double size, double borderWidth = 2}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300, width: borderWidth),
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.shield,
                    size: size * 0.53,
                    color: Colors.grey,
                  );
                },
              ),
            )
          : Icon(Icons.shield, size: size * 0.53, color: Colors.grey),
    );
  }
}
