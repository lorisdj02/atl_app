import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TeamCreateButton extends StatelessWidget {
  const TeamCreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPlayer = userProvider.activeUser?.role == 'player';
    final isInTeam = userProvider.activeUser?.teamId != null;

    if (!isPlayer) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: isInTeam ? null : () {
        // TODO: Navigate to team creation screen
      },
      backgroundColor: isInTeam ? Colors.grey : Colors.green,
      label: Text(
        isInTeam ? 'Fai già parte di una squadra' : 'Crea una squadra',
        style: const TextStyle(fontSize: 14),
      ),
      icon: const Icon(Icons.add),
    );
  }
}
