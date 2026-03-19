import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../models/sport.dart';
import '../utils/atl_colors.dart';
import '../database/db_read.dart';
import '../config/api_json_keys.dart';
import '../l10n/app_localizations.dart';

/// Widget per la selezione dello sport all'interno di una categoria
class SportSelectorWidget extends StatefulWidget {
  final SportCategory sportCategory;
  final Sport? selectedSport;
  final Function(Sport) onSportSelected;
  final String? title;
  final String? subtitle;

  const SportSelectorWidget({
    super.key,
    required this.sportCategory,
    this.selectedSport,
    required this.onSportSelected,
    this.title,
    this.subtitle,
  });

  @override
  State<SportSelectorWidget> createState() => _SportSelectorWidgetState();
}

class _SportSelectorWidgetState extends State<SportSelectorWidget> {
  List<Sport> _availableSports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  Future<void> _loadSports() async {
    final l10n = AppLocalizations.of(context);
    try {
      final List<Sport> data = await DBRead.getSportsByCategory(widget.sportCategory);
      setState(() {
        _availableSports = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingData(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableSports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noSportsAvailable,
            style: TextStyle(fontSize: 16, color: ATLColors.subtext),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title ?? l10n.selectSport,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: const TextStyle(fontSize: 14, color: ATLColors.subtext),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),

        // Sport cards
        ..._availableSports.map((sport) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SportCard(
              sport: sport,
              isSelected: widget.selectedSport?.id == sport.id,
              onTap: () => widget.onSportSelected(sport),
            ),
          );
        }),
      ],
    );
  }
}

/// Card per ogni sport
class _SportCard extends StatelessWidget {
  final Sport sport;
  final bool isSelected;
  final VoidCallback onTap;

  const _SportCard({
    required this.sport,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = ATLColors.getPrimaryColor(sport.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                sport.category.icon,
                size: 32,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 16),

            // Sport info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sport.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : ATLColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.sportPlayersMinutesLabel(
                      sport.minPlayersPerTeam,
                      sport.maxPlayersPerTeam,
                      sport.minutesPerRound,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: ATLColors.subtext,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 28),
          ],
        ),
      ),
    );
  }
}
