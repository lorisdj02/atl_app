import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../database/db_controller.dart';
import '../models/player.dart';
import '../models/user.dart';

class TeamCreateButton extends StatefulWidget {
  const TeamCreateButton({super.key});

  @override
  State<TeamCreateButton> createState() => _TeamCreateButtonState();
}

class _TeamCreateButtonState extends State<TeamCreateButton> {
  bool _isLoading = true;
  bool _isInTeam = false;

  @override
  void initState() {
    super.initState();
    _checkTeamStatus();
  }

  Future<void> _checkTeamStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPlayer = userProvider.activeUser?.role == UserRole.player;
    
    if (!isPlayer || userProvider.isGuest) {
      setState(() {
        _isLoading = false;
        _isInTeam = false;
      });
      return;
    }

    try {
      final Player? currentPlayer = await DB.Players.getById(userProvider.activeUser!.id);
      if (currentPlayer != null) {
        final playsAtList = await DB.PlaysAt.getByPlayerId(currentPlayer.playerId);
        setState(() {
          _isInTeam = playsAtList.isNotEmpty;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isInTeam = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInTeam = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPlayer = userProvider.activeUser?.role == UserRole.player;

    if (!isPlayer || userProvider.isGuest) return const SizedBox.shrink();

    if (_isLoading) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: Colors.grey,
        label: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        icon: const Icon(Icons.add),
      );
    }

    return FloatingActionButton.extended(
      onPressed: _isInTeam ? null : () {
        // TODO: Navigate to team creation screen
      },
      backgroundColor: _isInTeam ? Colors.grey : Colors.green,
      label: Text(
        _isInTeam ? 'Fai già parte di una squadra' : 'Crea una squadra',
        style: const TextStyle(fontSize: 14),
      ),
      icon: const Icon(Icons.add),
    );
  }
}
