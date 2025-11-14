import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sport_category.dart';
import '../providers/user_provider.dart';
import '../utils/atl_colors.dart';
import '../widgets/atl_floating_button.dart';

class MyTeamScreen extends StatelessWidget {
  final SportCategory currentSport;

  const MyTeamScreen({
    super.key,
    required this.currentSport,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final hasTeam = userProvider.activeUser?.team != null;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MY TEAM',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  color: currentSport.primaryColor,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  hasTeam ? 'Il tuo team' : 'Non fai parte di nessun team',
                  style: const TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming soon',
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Floating Action Button "New" - SOLO se non ha una squadra
          if (!hasTeam)
            Positioned(
              right: 16,
              bottom: 16,
              child: ATLFloatingButton(
                onPressed: () {
                  // TODO: Navigare a schermata creazione team
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creazione team coming soon')),
                  );
                },
                backgroundColor: currentSport.primaryColor,
                icon: Icons.add,
                label: 'New',
              ),
            ),
        ],
      ),
    );
  }
}
