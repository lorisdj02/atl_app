import 'package:atl_app/database/services/booking_service.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/field.dart';
import '../utils/atl_colors.dart';
import '../models/sport_category.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';

class BookingWidget extends StatefulWidget {
  final Field field;
  final DateTime startTime;
  final DateTime finishTime;
  final String? ownerUsername;
  final SportCategory currentSport;
  final VoidCallback? onBookingDeleted; // ← Aggiungi questo
  final bool isDeletable;
  final String completeAddress;
  final dynamic booking;
  final int? playersPaid;

  const BookingWidget({
    super.key,
    required this.field,
    required this.startTime,
    required this.finishTime,
    this.ownerUsername,
    required this.currentSport,
    this.onBookingDeleted, // ← Aggiungi
    this.isDeletable = true,
    required this.completeAddress,
    required this.booking,
    this.playersPaid,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final playerId = userProvider.activeRoleId!;
    LobbyBooking? _lobbyBooking;
    bool isOwner = false;
    if (widget.booking is LobbyBooking) {
      _lobbyBooking = widget.booking as LobbyBooking;
      isOwner = _lobbyBooking.ownerPlayerId == playerId;
    }

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');
    final isLobby = _lobbyBooking != null;
    final isFull = isLobby && _lobbyBooking.playersToFind == 0;

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
                    Icon(Icons.stadium, color: ATLColors.darkBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.field.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.title,
                            ),
                          ),
                          Text(
                            widget.completeAddress.isNotEmpty
                                ? '${l10n.locationLabel}: ${widget.completeAddress}'
                                : l10n.unknownAddress,
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
                    Icon(
                      Icons.calendar_today,
                      color: ATLColors.darkBlue,
                      size: 20,
                    ),
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
                    Icon(
                      Icons.access_time,
                      color: ATLColors.darkBlue,
                      size: 20,
                    ),
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
                if (isLobby) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.ownerDetail(widget.ownerUsername ?? l10n.unknown),
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
                        '${_lobbyBooking.totalPlayers - _lobbyBooking.playersToFind}/${_lobbyBooking.totalPlayers} ${l10n.players}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isFull ? Colors.red : ATLColors.title,
                        ),
                      ),
                      if (isFull) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.fullLobby.toUpperCase(),
                            style: const TextStyle(
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
                if (widget.playersPaid != null && widget.playersPaid! > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.payment, color: ATLColors.darkBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.youPaidForPlayers(widget.playersPaid!),
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
                if (isLobby &&
                    widget.playersPaid != null &&
                    widget.playersPaid! > 0) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementare chat
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.chatComingSoonWidget)),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(
                        l10n.openChat.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ATLColors.getPrimaryColor(
                          widget.currentSport,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                // Pulsante DELETE
                if (widget.isDeletable) ...[
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
                            title = l10n.deleteLobbyTitle;
                            message = l10n.deleteLobbyMessage;
                          } else {
                            title = l10n.leaveLobbyTitle;
                            message = l10n.leaveLobbyMessage;
                          }
                        } else {
                          title = l10n.deleteBookingTitle;
                          message = l10n.deleteBookingMessage;
                        }

                        // Mostra il dialogo di conferma
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(title),
                            content: Text(message),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(l10n.cancel.toUpperCase()),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(l10n.confirmButton),
                              ),
                            ],
                          ),
                        );

                        // Se l'utente conferma, procedi con l'eliminazione
                        if (confirm == true) {
                          try {
                            if (isLobby) {
                              await BookingService.Write.leaveLobbyBooking(
                                widget.booking.id,
                              );
                            } else {
                              await BookingService.Write.refundPrivateBooking(
                                widget.booking.id,
                              );
                            }
                            widget.onBookingDeleted
                                ?.call(); // ← Chiama il callback
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isLobby && isOwner
                                        ? l10n.lobbyDeleted
                                        : isLobby
                                        ? l10n.lobbyLeft
                                        : l10n.bookingDeleted,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isLobby && isOwner
                                        ? l10n.failedToDeleteLobby
                                        : isLobby
                                        ? l10n.failedToLeavelobby
                                        : l10n.failedToDeleteBooking,
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(
                        isLobby && isOwner
                            ? l10n.deleteLobbyTitle.toUpperCase()
                            : isLobby
                            ? l10n.leaveLobbyTitle.toUpperCase()
                            : l10n.deleteBookingTitle.toUpperCase(),
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
  }
}
