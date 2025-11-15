import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';
import '../database/db_controller.dart';

/// Widget per visualizzare un team con logo, nome, captain e numero giocatori
class TeamWidget extends StatelessWidget {
  final Team team;
  final Color color;
  final String? imageUrl;
  final int? rankPts;

  const TeamWidget({
    super.key,
    required this.team,
    this.color = Colors.white,
    this.imageUrl,
    this.rankPts,
  });

  Future<String> _getCaptainName() async {
    final captain = await DB.Players.getByPlayerId(team.captainId);
    return captain?.username ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCaptainName(),
      builder: (context, snapshot) {
        // Mostra placeholder mentre carica
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(16),
            height: 92,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ATLColors.darkBlue,
                ),
              ),
            ),
          );
        }

        final captainName = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo del team (placeholder circolare)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shield, size: 32, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.shield, size: 32, color: Colors.grey),
              ),
              
              const SizedBox(width: 16),
              
              // Informazioni del team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome del team
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Nome del capitano
                    Text(
                      'Captain: $captainName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge giocatori e punti (se presenti)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badge numero giocatori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ATLColors.darkBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: ATLColors.darkBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${team.players}/24',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ATLColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Punti ranking (solo in Ranks)
                  if (rankPts != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$rankPts pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],

                  // Badge VIP (se applicabile)
                  if (team.vip) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
