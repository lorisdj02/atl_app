import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

enum UserRole {
  coordinator,
  player,
  referee,
  organization,
}

/// Widget per la selezione del ruolo utente
class ATLRoleSelector extends StatelessWidget {
  final UserRole role;
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
      case UserRole.coordinator:
        return Icons.assignment;
      case UserRole.player:
        return Icons.person;
      case UserRole.referee:
        return Icons.gavel;
      case UserRole.organization:
        return Icons.business;
    }
  }

  String _getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (role) {
      case UserRole.coordinator:
        return loc.coordinator;
      case UserRole.player:
        return loc.player;
      case UserRole.referee:
        return loc.referee;
      case UserRole.organization:
        return loc.organization;
    }
  }

  String _getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (role) {
      case UserRole.coordinator:
        return loc.coordinatorDesc;
      case UserRole.player:
        return loc.playerDesc;
      case UserRole.referee:
        return loc.refereeDesc;
      case UserRole.organization:
        return loc.organizationDesc;
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
              child: Icon(
                _icon,
                color: Colors.white,
                size: 30,
              ),
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
