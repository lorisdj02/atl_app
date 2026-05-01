import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/account_role.dart';

/// Widget per la selezione del ruolo utente
class ATLRoleSelector extends StatelessWidget {
  final AccountRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const ATLRoleSelector({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (role) {
      case AccountRole.coordinator:
        return Icons.assignment;
      case AccountRole.player:
        return Icons.person;
      case AccountRole.referee:
        return Icons.gavel;
      case AccountRole.organization:
        return Icons.business;
      default:
        return Icons.visibility;
    }
  }

  String _getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (role) {
      case AccountRole.coordinator:
        return loc.coordinator;
      case AccountRole.player:
        return loc.player;
      case AccountRole.referee:
        return loc.referee;
      case AccountRole.organization:
        return loc.organization;
      default:
        return '';
    }
  }

  String _getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (role) {
      case AccountRole.coordinator:
        return loc.coordinatorDesc;
      case AccountRole.player:
        return loc.playerDesc;
      case AccountRole.referee:
        return loc.refereeDesc;
      case AccountRole.organization:
        return loc.organizationDesc;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: ATLColors.darkBlue, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icona circolare
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ATLColors.darkBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            // Titolo e sottotitolo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(context),
                    style: const TextStyle(
                      color: ATLColors.subtext,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(context),
                    style: const TextStyle(
                      color: ATLColors.title,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
