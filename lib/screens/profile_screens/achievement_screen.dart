import 'package:flutter/material.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';

class AchievementScreen extends StatelessWidget {
  final SportCategory currentSport;

  const AchievementScreen({super.key, required this.currentSport});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.achievementsTitle,
          style: const TextStyle(
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
            Text(
              l10n.comingSoon,
              style: const TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                l10n.achievementsComingSoon,
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
