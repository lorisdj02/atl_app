import 'package:atl_app/models/lobby_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_controller.dart';
import '../models/field.dart';
import '../models/player.dart';
import '../utils/atl_colors.dart';
import '../models/sport_category.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class BookingWidget extends StatefulWidget {
  final int fieldId;
  final DateTime startTime;
  final DateTime finishTime;
  final int? ownerId;
  final SportCategory currentSport;
  final int bookingId;
  final int playerPaid;
  final VoidCallback? onBookingDeleted; // ← Aggiungi questo
  final bool isDeletable;

  const BookingWidget({
    super.key,
    required this.fieldId,
    required this.startTime,
    required this.finishTime,
    this.ownerId,
    required this.currentSport,
    required this.bookingId,
    this.playerPaid = 0,
    this.onBookingDeleted, // ← Aggiungi 
    this.isDeletable = true,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  Field? _field;
  Player? _owner;
  bool _isLoading = true;
  bool _isParticipating = false;
  int _currentParticipants = 0;
  int _maxParticipants = 0;
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final field = await DB.Fields.getById(widget.fieldId);
      
      Player? owner;
      bool isParticipating = false;
      int currentParticipants = 0;
      int maxParticipants = 0;

      
      if (widget.ownerId != null) {
        owner = await DB.Players.getByPlayerId(widget.ownerId!);
        
        // Check if current user is participating
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final playerId = userProvider.activeRoleId;
        isParticipating = await DB.LobbyBookingParticipations.isParticipating(
              playerId!,
              widget.bookingId,
            );
        
        // Carica numero partecipanti
        currentParticipants = await DB.LobbyBookingParticipations.getParticipantCount(widget.bookingId);
        maxParticipants = await DB.LobbyBookings.getMaxParticipants(widget.bookingId);
      }
      
      if (mounted) {
        setState(() {
          _field = field;
          _owner = owner;
          _isParticipating = isParticipating;
          _currentParticipants = currentParticipants;
          _maxParticipants = maxParticipants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final playerId = userProvider.activeRoleId!;
    bool isOwner = widget.ownerId == playerId;
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_field == null) {
          return const Center(child: Text('Field not found'));
        }

        final dateFormat = DateFormat('EEE, MMM d');
        final timeFormat = DateFormat('HH:mm');
        final isLobby = widget.ownerId != null;
        final isFull = isLobby && _currentParticipants >= _maxParticipants;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card principale
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome campo
                    Row(
                      children: [
                        Icon(
                          Icons.stadium,
                          color: ATLColors.darkBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _field!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: ATLColors.title,
                                ),
                              ),
                              Text(
                                _field!.city,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ATLColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Data e orario
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: ATLColors.darkBlue, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          dateFormat.format(widget.startTime),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ATLColors.title,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.access_time, color: ATLColors.darkBlue, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${timeFormat.format(widget.startTime)} - ${timeFormat.format(widget.finishTime)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ATLColors.title,
                          ),
                        ),
                      ],
                    ),

                    // Owner (solo per lobby)
                    if (isLobby && _owner != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Owner: ${_owner!.username}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ATLColors.title,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Numero partecipanti (solo per lobby)
                    if (isLobby) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.group, color: ATLColors.darkBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '$_currentParticipants/$_maxParticipants',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isFull ? Colors.red : ATLColors.title,
                            ),
                          ),
                          if (isFull) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'FULL LOBBY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Player paid info
                    if (widget.playerPaid > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.payment, color: ATLColors.darkBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'You paid for ${widget.playerPaid} player${widget.playerPaid > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ATLColors.title,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Pulsante chat (solo per lobby SE si partecipa)
                    if (isLobby && _isParticipating) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementare chat
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat - Coming soon')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text(
                            'OPEN CHAT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Pulsante DELETE
                    if (widget.isDeletable)...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Determina il messaggio in base al tipo di azione
                          String title;
                          String message;
                          
                          if (isLobby) {
                            if (isOwner) {
                              title = 'Delete Lobby';
                              message = 'Are you sure you want to delete this lobby? All participants will be removed.';
                            } else {
                              title = 'Leave Lobby';
                              message = 'Are you sure you want to leave this lobby?';
                            }
                          } else {
                            title = 'Delete Booking';
                            message = 'Are you sure you want to delete this private booking?';
                          }

                          // Mostra il dialogo di conferma
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(title),
                              content: Text(message),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('CONFIRM'),
                                ),
                              ],
                            ),
                          );

                          // Se l'utente conferma, procedi con l'eliminazione
                          if (confirm == true) {
                            bool success = false;
                            if (isLobby) {
                              if(isOwner) {
                                success = await DB().deleteLobby(widget.bookingId);
                              }
                              else {
                                success = await DB().leaveLobby(widget.bookingId, playerId);
                              }
                            } else {
                              success = await DB.PrivateBookings.deletePrivateBooking(widget.bookingId);
                            }

                            if (success) {
                              widget.onBookingDeleted?.call(); // ← Chiama il callback
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(isLobby && isOwner ? 'Lobby deleted' : isLobby ? 'Lobby left' : 'Booking deleted')),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete ${isLobby && isOwner ? 'lobby' : isLobby ? 'lobby participation' : 'booking'}')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(
                          isLobby && isOwner ? 'DELETE LOBBY' : isLobby ? 'LEAVE LOBBY' : 'DELETE BOOKING',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
