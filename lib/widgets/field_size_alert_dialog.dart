import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/field.dart';

/// Dialog to warn users when they select an oversized field
/// that's bigger than needed for their sport/player count.
class FieldSizeAlertDialog extends StatelessWidget {
  final Field field;
  final int maxPlayers;
  final VoidCallback onConfirm;
  final String? customMessage;

  const FieldSizeAlertDialog({
    super.key,
    required this.field,
    required this.onConfirm,
    required this.maxPlayers,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        l10n.oversizedFieldDialogTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        customMessage ?? l10n.oversizedFieldDialogMessage(maxPlayers),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(l10n.continueButton),
        ),
      ],
    );
  }
}
