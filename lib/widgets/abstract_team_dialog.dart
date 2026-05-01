import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

/// Classe astratta per i dialog che permettono la selezione di un team
abstract class AbstractTeamDialog extends StatefulWidget {
  final Team homeTeam;
  final Team awayTeam;
  final double tournamentId;
  final double matchId;
  final SportCategory sportCategory;

  const AbstractTeamDialog({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.tournamentId,
    required this.matchId,
    required this.sportCategory,
  });
}

/// Mixin per aggiungere funzionalità comuni agli stati dei dialog team
mixin TeamDialogMixin<T extends AbstractTeamDialog> on State<T> {
  Team? selectedTeam;
  bool isLoading = false;

  /// Costruisce il widget di selezione del team
  Widget buildTeamSelector({
    required Team team,
    required bool isHome,
    required VoidCallback onTap,
    Widget? customTeamDisplay,
  }) {
    final isSelected = selectedTeam?.id == team.id;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? ATLColors.getPrimaryColor(
                    widget.sportCategory,
                  ).withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ATLColors.getPrimaryColor(widget.sportCategory)
                  : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
          ),
          child:
              customTeamDisplay ??
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: team.logoUrl != null
                        ? NetworkImage(team.logoUrl!)
                        : null,
                    child: team.logoUrl == null
                        ? Text(
                            team.name[0],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.darkBlue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: ATLColors.darkBlue,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
        ),
      ),
    );
  }

  /// Costruisce il widget di intestazione del dialog
  Widget buildDialogHeader({required String title, VoidCallback? onClose}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ATLColors.darkBlue,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Costruisce il widget di avviso quando non è stato selezionato un team
  Widget buildNoTeamSelectedWarning() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.pleaseSelectTeamFirst,
              style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
