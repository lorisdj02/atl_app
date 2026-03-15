import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const Text(
        'Campo sovradimensionato',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        customMessage ??
            'Il campo è pensato per più giocatori (${maxPlayers} totali). '
                'Questo potrebbe significare una differente esperienza di gioco '
                'ed una fee maggiore. Vuoi continuare?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Continua'),
        ),
      ],
    );
  }
}
