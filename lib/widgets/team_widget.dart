import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';

/// Widget per visualizzare un team con logo, nome, captain e numero giocatori
class TeamWidget extends StatelessWidget {
  final Team team;
  final Color color;
  final String? imageUrl;
  final int? rankPts;
  final String? captainName;
  final bool isStandingsView;
  final bool isHomeView;
  final int? rank;
  final String? standingRecord;

  const TeamWidget({
    super.key,
    required this.team,
    this.color = Colors.white,
    this.imageUrl,
    this.rankPts,
    this.captainName,
    this.isStandingsView = false,
    this.isHomeView = false,
    this.rank,
    this.standingRecord,
  });

  @override
  Widget build(BuildContext context) {
    if (isHomeView) {
      return _buildHomeView();
    }
    if (isStandingsView) {
      return _buildStandingsView();
    }
    return _buildDefaultView();
  }

  Widget _buildHomeView() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.soccerGreen ? Colors.white : ATLColors.darkBlue,
              ),
            ),
          ),
          // Logo
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
                        return const Icon(Icons.shield, size: 28, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.shield, size: 28, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Team name
          Expanded(
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.soccerGreen ? Colors.white : Colors.black,
                height: 1.2,
              ),
            ),
          ),
          // Points only
          if (standingRecord != null)
            Text(
              standingRecord!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.soccerGreen ? Colors.white : ATLColors.darkBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandingsView() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? ATLColors.darkBlue : Colors.white,
              ),
            ),
          ),
          // Logo
          Container(
            width: 40,
            height: 40,
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
                        return const Icon(Icons.shield, size: 24, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.shield, size: 24, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Team name
          Expanded(
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? Colors.black : Colors.white,
              ),
            ),
          ),
          // Full record (Pts - W - D - L)
          if (standingRecord != null)
            Text(
              standingRecord!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? ATLColors.darkBlue : Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultView() {
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
                  'Captain: ${captainName ?? 'Loading...'}',
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
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: ATLColors.darkBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${team.players}/24',
                      style: const TextStyle(
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
  }
}
