import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/player.dart';
import '../models/team_request.dart';

class PlayerRequestWidget extends StatelessWidget {
  final TeamRequest request;
  final Player? player;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PlayerRequestWidget({
    super.key,
    required this.request,
    required this.player,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: player?.imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      player!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          // Player name
          Expanded(
            child: Text(
              player?.username ?? '${l10n.player} ${request.playerId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // Accept button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white, size: 20),
              onPressed: onAccept,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          // Reject button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade400,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onReject,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
