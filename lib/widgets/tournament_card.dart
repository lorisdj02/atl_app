import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';

/// Stato del torneo per l'utente
enum TournamentUserStatus {
  none,        // Non partecipa
  favorite,    // Aggiunto ai preferiti
  participating, // Sta partecipando
}

/// Widget per visualizzare una card torneo
class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final SportCategory currentSport;
  final TournamentUserStatus userStatus;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.currentSport,
    this.userStatus = TournamentUserStatus.none,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo/Color indicator + Coordinator + Teams count + Favorite
            Row(
              children: [
                // Logo ATL o color indicator
                _buildLeadingIndicator(),
                const SizedBox(width: 12),
                
                // Coordinator info
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: ATLColors.darkBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Coordinator${tournament.coordinatorId}', // TODO: Nome coordinatore reale
                        style: const TextStyle(
                          fontSize: 12,
                          color: ATLColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Teams count
                Row(
                  children: [
                    const Icon(Icons.group, size: 16, color: ATLColors.darkBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${tournament.paidTeams}/${tournament.numTeams}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 12),
                
                // Favorite button
                if (_canAddToFavorites())
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      userStatus == TournamentUserStatus.none
                          ? Icons.favorite_border
                          : Icons.favorite,
                      color: _getFavoriteColor(),
                      size: 24,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Tournament name + Prize
            Row(
              children: [
                Expanded(
                  child: Text(
                    tournament.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ATLColors.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Prize in grassetto affianco al nome
                Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      tournament.formattedPrize1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Location and fee
            Row(
              children: [
                // Location
                const Icon(Icons.location_on, size: 16, color: ATLColors.subtext),
                const SizedBox(width: 4),
                Text(
                  'Field, ${tournament.cityName}', // TODO: Nome campo reale
                  style: const TextStyle(
                    fontSize: 12,
                    color: ATLColors.subtext,
                  ),
                ),
                
                const Spacer(),
                
                // Fee
                const Icon(Icons.payments, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  tournament.formattedFee,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Background color basato sullo stato del torneo
  Color _getBackgroundColor() {
    if (tournament.atlEvent) {
      return const Color(0xFF9FE2BF); // Verde ATL
    } else if (tournament.paidTeams >= tournament.numTeams) {
      return const Color(0xFFC5C5C5); // Grigio se torneo pieno
    } else {
      return Colors.white; // Bianco default
    }
  }

  /// Leading indicator: Logo ATL o color indicator
  Widget _buildLeadingIndicator() {
    if (tournament.atlEvent) {
      // Logo ATL
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            'images/logo_vertical.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.sports_soccer, color: ATLColors.darkBlue);
            },
          ),
        ),
      );
    } else {
      // Color indicator per livello coordinatore
      return Container(
        width: 8,
        height: 40,
        decoration: BoxDecoration(
          color: _getCoordinatorLevelColor(),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
  }

  /// Colore basato sul livello del coordinatore
  Color _getCoordinatorLevelColor() {
    // TODO: Implementare logica livelli coordinatore
    // Per ora tutto verde
    return Colors.green;
  }

  /// Colore del cuore preferiti
  Color _getFavoriteColor() {
    switch (userStatus) {
      case TournamentUserStatus.participating:
        return Colors.green; // Verde se partecipo
      case TournamentUserStatus.favorite:
        return ATLColors.darkBlue; // Blu ATL se preferito
      case TournamentUserStatus.none:
        return ATLColors.darkBlue; // Blu ATL per outline
    }
  }

  /// Verifica se si può aggiungere ai preferiti
  bool _canAddToFavorites() {
    // Non mostrare cuore se torneo è finito o cancellato
    return tournament.status != TournamentStatus.finished &&
           tournament.status != TournamentStatus.canceled;
  }
}
