import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../database/db_controller.dart';
import '../screens/tournaments/tournament_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Widget per visualizzare una card torneo

class TournamentCard extends StatefulWidget{
 final Tournament tournament;
  final SportCategory currentSport;
  final VoidCallback? onTap;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.currentSport,
    this.onTap,
  });

  @override
  State<TournamentCard> createState() => _TournamentCardStatus();
}
class _TournamentCardStatus extends State<TournamentCard>{
  
  late bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.tournament.isFavorite ?? false;
  }


  Future<Map<String, String>> _loadCardData() async {
    final coordinator = await DB.Coordinators.getByCoordinatorId(widget.tournament.coordinatorId);
    final field = await DB.Fields.getById(widget.tournament.fieldId);
    
    return {
      'coordinatorUsername': coordinator?.username ?? 'Unknown',
      'fieldName': field?.name ?? 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadCardData(),
      builder: (context, snapshot) {
        // Mostra placeholder mentre carica
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ATLColors.darkBlue,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        
        return GestureDetector(
          onTap: () {
            // Naviga alla schermata di dettaglio del torneo
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
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
                            data['coordinatorUsername']!,
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
                          '${widget.tournament.paidTeams}/${widget.tournament.numTeams}',
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
                        onTap: () {
                          setState(() {
                            // Toggle favorite/participating status
                              if(widget.tournament.isParticipating!){
                                // Se partecipo, non posso togliere il preferito
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Cannot change favorite status while participating.'),
                                  duration: Duration(seconds: 2),
                                ));
                                return;
                              }

                              int userId = Provider.of<UserProvider>(context, listen: false).activeUser!.id;
                              Future.microtask(() async {
                              await DB.Tournaments.toggleFavoriteStatus(
                                widget.tournament.id,
                                userId,
                              );});

                              isFavorite = !isFavorite;

                              print('Tournament ${widget.tournament.id} favorite status: $isFavorite');
                          });
                        },
                        child: Icon(
                          _getFavoriteIcon(),
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
                        widget.tournament.name,
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
                          widget.tournament.formattedPrize1,
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
                      '${data['fieldName']!}, ${widget.tournament.city}',
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
                      widget.tournament.formattedFee,
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
      },
    );
  }

  /// Background color basato sullo stato del torneo
  Color _getBackgroundColor() {
    if (widget.tournament.isATL) {
      return ATLColors.getSecondaryColor(widget.currentSport); // Verde ATL
    } else if (widget.tournament.paidTeams >= widget.tournament.numTeams) {
      return const Color(0xFFC5C5C5); // Grigio se torneo pieno
    } else {
      return Colors.white; // Bianco default
    }
  }

  /// Leading indicator: Logo ATL o color indicator
  Widget _buildLeadingIndicator() {
    if (widget.tournament.isATL) {
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

  /// Icona del cuore (pieno o vuoto)
  IconData _getFavoriteIcon() {
    return (widget.tournament.isParticipating! || isFavorite)
        ? Icons.favorite
        : Icons.favorite_border;
  }

  /// Colore del cuore preferiti
  Color _getFavoriteColor() {
    if (widget.tournament.isParticipating!) {
      return ATLColors.getPrimaryColor(widget.currentSport); // Verde se partecipo (precedenza)
    } else if (isFavorite) {
      return ATLColors.darkBlue; // Blu ATL se preferito
    } else {
      return ATLColors.darkBlue; // Blu ATL per outline
    }
  }

  /// Verifica se si può aggiungere ai preferiti
  bool _canAddToFavorites() {
    // Non mostrare cuore se torneo è finito o cancellato
    return widget.tournament.status != TournamentStatus.finished &&
           widget.tournament.status != TournamentStatus.canceled;
  }
}
