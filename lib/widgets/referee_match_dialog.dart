import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';

class RefereeMatchDialog extends StatelessWidget {
  final List<String> availableRoles;
  final SportCategory sportCategory;

  const RefereeMatchDialog({
    super.key,
    required this.availableRoles,
    required this.sportCategory,
  });

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'MAIN':
        return 'Main Referee';
      case 'ASSISTANT1':
        return 'Assistant Referee 1';
      case 'ASSISTANT2':
        return 'Assistant Referee 2';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Text(
                    'Referee this Match',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Select your role:',
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
                    _getRoleDisplayName(role),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Assignment'),
        content: Text(
          'Are you sure you want to referee this match as ${_getRoleDisplayName(role)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(sportCategory),
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, role);
    }
  }
}
