import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/atl_colors.dart';

class FootballStatCard extends StatelessWidget {
  final int goals;
  final int motm;
  final int yellowCards;
  final int redCards;

  const FootballStatCard({
    super.key,
    required this.goals,
    required this.motm,
    required this.yellowCards,
    required this.redCards,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          _StatItem(
            icon: Icons.sports_soccer,
            color: ATLColors.darkBlue,
            value: goals,
            label: l10n.goalsLabel,
          ),
          _StatItem(
            icon: Icons.star_rounded,
            color: Colors.amber,
            value: motm,
            label: l10n.motmLabel,
          ),
          _StatItem(
            icon: Icons.rectangle,
            color: Colors.amber.shade700,
            value: yellowCards,
            label: l10n.yellowCardsLabel,
          ),
          _StatItem(
            icon: Icons.rectangle,
            color: Colors.red,
            value: redCards,
            label: l10n.redCardsLabel,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: ATLColors.darkBlue,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: ATLColors.subtext, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
