import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

class RefereeMatchDialog extends StatelessWidget {
  final List<String> availableRoles;
  final SportCategory sportCategory;
  final Map<String, double> payPerRole;

  const RefereeMatchDialog({
    super.key,
    required this.availableRoles,
    required this.sportCategory,
    required this.payPerRole,
  });

  String _getRoleDisplayName(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case 'MAIN':
        return l10n.mainRefereeRole;
      case 'ASSISTANT1':
        return l10n.assistantRef1Role;
      case 'ASSISTANT2':
        return l10n.assistantRef2Role;
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports,
                  color: ATLColors.getPrimaryColor(sportCategory),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.refereeThisMatchTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectYourRoleLabel,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...availableRoles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () => _showConfirmationDialog(context, role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ATLColors.getPrimaryColor(sportCategory),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${_getRoleDisplayName(context, role)} - \$${payPerRole[role]?.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    String role,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Assignment'),
        content: Text(
          l10n.confirmRefereeMsg(_getRoleDisplayName(context, role)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(sportCategory),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, role);
    }
  }
}
