import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/match_booking.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/atl_colors.dart';
import '../models/sport_category.dart';
import '../models/team.dart';
import '../models/booking.dart';
import '../models/field.dart';
import '../l10n/app_localizations.dart';

// OrganizationBookingWidget: shows a booking card for match, lobby, or private booking
class OrganizationBookingWidget extends StatefulWidget {
  final Booking booking;
  final SportCategory currentSport;

  final Team? homeTeam;
  final Team? awayTeam;
  final Field field;

  final LobbyBooking? lobbyBooking;
  final PrivateBooking? privateBooking;
  final MatchBooking? matchBooking;

  final String? playerString;
  final String? coordinatorString;

  const OrganizationBookingWidget({
    super.key,
    required this.booking,
    required this.currentSport,
    required this.field,
    this.homeTeam,
    this.awayTeam,
    this.playerString,
    this.coordinatorString,
    this.lobbyBooking,
    this.privateBooking,
    this.matchBooking,
  });

  @override
  State<OrganizationBookingWidget> createState() =>
      _OrganizationBookingWidgetState();
}

class _OrganizationBookingWidgetState extends State<OrganizationBookingWidget> {
  bool _isLoading = true;
  bool _isMatchBooking = false;

  bool _isLobbyBooking = false;

  bool _isPrivateBooking = false;

  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = false;
      _isMatchBooking = widget.booking.type == BookingType.match;
      _isLobbyBooking = widget.booking.type == BookingType.lobby;
      _isPrivateBooking = widget.booking.type == BookingType.private;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const SizedBox(
            height: 250, // Altezza fissa simile al card finale per evitare jump
            child: Center(child: CircularProgressIndicator()),
          );
        } else {
          return _buildBookingCard();
        }
      },
    );
  }

  Widget _buildBookingCard() {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    return Container(
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
          // Titolo e campo
          if (_isMatchBooking) ...[
            Row(
              children: [
                Icon(Icons.sports_soccer, color: ATLColors.darkBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.tournamentMatchLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ATLColors.title,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_isLobbyBooking) ...[
            Row(
              children: [
                Icon(Icons.group, color: ATLColors.darkBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.lobbyBookingType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ATLColors.title,
                        ),
                      ),
                      Text(
                        widget.field.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: ATLColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else if (_isPrivateBooking) ...[
            Row(
              children: [
                Icon(Icons.lock, color: ATLColors.darkBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.privateBookingType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ATLColors.title,
                        ),
                      ),
                      Text(
                        widget.field.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: ATLColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Per match: squadre
          if (_isMatchBooking) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeam(widget.homeTeam),
                Text(
                  l10n.vsLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.subtext,
                  ),
                ),
                _buildTeam(widget.awayTeam),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
          ],

          // Data e orario
          Row(
            children: [
              Icon(Icons.calendar_today, color: ATLColors.darkBlue, size: 20),
              const SizedBox(width: 12),
              Text(
                dateFormat.format(widget.booking.startTime),
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
                '${timeFormat.format(widget.booking.startTime)} - ${timeFormat.format(widget.booking.finishTime)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ATLColors.title,
                ),
              ),
            ],
          ),

          // Per match: coordinator e scheduled start
          if (_isMatchBooking) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.coordinatorPrefix(widget.coordinatorString ?? 'N/A'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ATLColors.title,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Per lobby: owner e partecipanti
          if (_isLobbyBooking) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.ownerDetail(widget.playerString ?? 'N/A'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ATLColors.title,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.group, color: ATLColors.darkBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${(widget.lobbyBooking!.maxPlayers) - (widget.lobbyBooking!.playersToFind)}/${widget.lobbyBooking!.maxPlayers}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (widget.lobbyBooking!.playersToFind) == 0
                        ? Colors.red
                        : ATLColors.title,
                  ),
                ),
                if ((widget.lobbyBooking!.playersToFind) == 0) ...[
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

          // Per private: player
          if (_isPrivateBooking) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.playerPrefix(widget.playerString ?? 'N/A'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ATLColors.title,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeam(Team? team) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Icon(Icons.shield, size: 28, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          team?.name ?? 'N/A',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: team == null ? ATLColors.subtext : Colors.black,
          ),
        ),
      ],
    );
  }
}
