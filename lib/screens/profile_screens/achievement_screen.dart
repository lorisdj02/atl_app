import 'package:flutter/material.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';

class AchievementScreen extends StatelessWidget {
  final SportCategory currentSport;

  const AchievementScreen({super.key, required this.currentSport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ACHIEVEMENTS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: ATLColors.subtext.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Coming Soon',
              style: TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Your achievements and palmares will be displayed here soon!',
                textAlign: TextAlign.center,
                style: TextStyle(color: ATLColors.subtext, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
