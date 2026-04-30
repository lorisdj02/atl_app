import 'package:flutter/material.dart';
import '../models/growth_step.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
class GrowthTimelineItem extends StatelessWidget {
  final GrowthStep step;
  final bool isLast;
  final int currentLevel;
  final Color catColor;
  final Color catColorLight;
  final bool isReferee;
  final bool isCoordinator;
  final Map<int, Map<SportCategory, double>> minPay;
  final Map<int, Map<SportCategory, double>> maxPay;

  const GrowthTimelineItem({
    super.key,
    required this.step,
    required this.isLast,
    required this.currentLevel,
    required this.catColor,
    required this.catColorLight,
    required this.isReferee,
    required this.isCoordinator,
    required this.minPay,
    required this.maxPay,
  });

  bool get _isCurrent => step.level == currentLevel;
  bool get _isCompleted => step.level < currentLevel;
  bool get _isFuture => step.level > currentLevel;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildNode(),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: _isCompleted
                            ? ATLColors.darkBlue.withOpacity(0.25)
                            : ATLColors.subtext.withOpacity(0.12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _buildStepCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode() {
    Color bg;
    if (_isCurrent) {
      bg = catColor;
    } else if (_isCompleted) {
      bg = ATLColors.darkBlue;
    } else {
      bg = ATLColors.subtext.withOpacity(0.18);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: _isCurrent ? Border.all(color: catColorLight, width: 2) : null,
      ),
      child: Center(
        child: _isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${step.level}',
                style: TextStyle(
                  color:
                      _isFuture ? ATLColors.subtext.withOpacity(0.4) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardBg = _isCurrent ? catColor.withOpacity(0.07) : Colors.white;
    final borderColor = _isCurrent ? catColor : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: _isCurrent ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: _isCurrent
                ? catColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isCurrent ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    color: _isFuture
                        ? ATLColors.subtext.withOpacity(0.45)
                        : ATLColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.currentBadge,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRequirements(context),
          const SizedBox(height: 10),
          _buildPayInfo(context),
        ],
      ),
    );
  }

  Widget _buildRequirements(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color =
        _isFuture ? ATLColors.subtext.withOpacity(0.4) : ATLColors.subtext;

    if (step.level == 1) {
      return _reqRow(
          Icons.flag_outlined, l10n.startingLevel, color);
    }

    if (isReferee) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reqRow(
            Icons.sports_score_outlined,
            l10n.minGamesRefereed(step.minRefereedMatches ?? 0),
            color,
          ),
          const SizedBox(height: 4),
          _reqRow(
            Icons.star_outline,
            l10n.avgRatingGames(step.minRatingOverLastXMatches ?? 0, step.x),
            color,
          ),
        ],
      );
    }

    if (isCoordinator) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reqRow(
            Icons.emoji_events_outlined,
            l10n.minTournamentsCoordinated(step.minCoordinatedTournaments ?? 0),
            color,
          ),
          const SizedBox(height: 4),
          _reqRow(
            Icons.star_outline,
            l10n.avgRatingTournaments(step.minRatingOverLastXTournaments ?? 0, step.x),
            color,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPayInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isReferee) {
      final chips = SportCategory.values.map((cat) {
        final min = minPay[step.level]?[cat];
        final max = maxPay[step.level]?[cat];
        if (min == null || max == null) return null;
        return _categoryPayChip(context, cat, min, max);
      }).whereType<Widget>().toList();

      if (chips.isEmpty) return const SizedBox.shrink();
      return Wrap(spacing: 8, runSpacing: 6, children: chips);
    }

    if (isCoordinator && step.coordinatorPayPerMatch != null) {
      final color =
          ATLColors.darkBlue.withOpacity(_isFuture ? 0.35 : 1.0);
      return _infoChip(
        icon: Icons.payments_outlined,
        text: l10n.payPerMatch(step.coordinatorPayPerMatch!.toStringAsFixed(2)),
        bg: ATLColors.darkBlue.withOpacity(_isFuture ? 0.05 : 0.08),
        color: color,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _categoryPayChip(BuildContext context, SportCategory cat, double min, double max) {
    final l10n = AppLocalizations.of(context);
    final base = ATLColors.getPrimaryColor(cat);
    final textColor = base.withOpacity(_isFuture ? 0.35 : 1.0);
    final payText = (min == max)
        ? l10n.payPerMatch(min.toStringAsFixed(2))
        : l10n.payPerMatch('€${min.toStringAsFixed(2)} – €${max.toStringAsFixed(2)}');

    return _infoChip(
      icon: cat.icon,
      text: '${cat.name}  •  $payText',
      bg: base.withOpacity(_isFuture ? 0.05 : 0.1),
      color: textColor,
    );
  }

  Widget _reqRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
