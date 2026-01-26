import 'package:atl_app/models/private_bookings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/atl_colors.dart';
import '../models/sport_category.dart';
import '../database/db_controller.dart';
import '../models/team.dart';
import '../models/booking.dart';
import '../models/field.dart';
import '../models/user.dart';

// OrganizationBookingWidget: shows a booking card for match, lobby, or private booking
class OrganizationBookingWidget extends StatefulWidget {
  final Booking booking;
  final SportCategory currentSport;

  const OrganizationBookingWidget({
    super.key,
    required this.booking,
    required this.currentSport,
  });

  @override
  State<OrganizationBookingWidget> createState() =>
      _OrganizationBookingWidgetState();
}

class _OrganizationBookingWidgetState extends State<OrganizationBookingWidget> {
  bool _isLoading = true;
  bool _isMatchBooking = false;
  Team? _homeTeam;
  Team? _awayTeam;
  User? _coordinator;
  DateTime? _scheduledStart;

  bool _isLobbyBooking = false;
  int? _playersFound; // for lobby bookings
  int? _maxPlayers; // for lobby bookings

  bool _isPrivateBooking = false;
  User? _player; // for private bookings

  Field? _field;
  String? cityName;
  User? _owner; // for lobby owner  Player? _player; // for private player  late Future<void> _loadDataFuture;

  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isMatchBooking = widget.booking.type == BookingType.match;
      _isLobbyBooking = widget.booking.type == BookingType.lobby;
      _isPrivateBooking = widget.booking.type == BookingType.private;
    });

    // Load field and city
    final field = await DB.Fields.getById(widget.booking.fieldId);
    if (field != null) {
      cityName = await DB.Cities.getById(
        field.cityId,
      ).then((city) => city?.name);
      setState(() {
        _field = field;
      });
    }

    if (_isMatchBooking) {
      _loadMatchData(widget.booking.id);
    } else if (_isLobbyBooking) {
      final lobbyBooking = await DB.LobbyBookings.getById(widget.booking.id);
      if (lobbyBooking != null) {
        final User? owner = await DB.Players.getByPlayerId(
          lobbyBooking.ownerId,
        );

        setState(() {
          _playersFound = lobbyBooking.maxPlayers - lobbyBooking.playersToFind;
          _maxPlayers = lobbyBooking.maxPlayers;
          _owner = owner;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_isPrivateBooking) {
      final PrivateBooking? privateBooking = await DB.PrivateBookings.getById(
        widget.booking.id,
      );
      if (privateBooking == null) {
        setState(() {
          _isLoading = false;
        });
      } else {
        final User? player = await DB.Players.getByPlayerId(
          privateBooking.playerId,
        );
        setState(() {
          _player = player;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMatchData(int matchId) async {
    if (widget.currentSport == SportCategory.football) {
      final match = await DB.FootballMatches.getById(matchId);
      if (match != null &&
          match.homeTeamId != null &&
          match.awayTeamId != null) {
        final homeTeam = await DB.Teams.getById(match.homeTeamId!);
        final awayTeam = await DB.Teams.getById(match.awayTeamId!);
        final coordinatorId = await DB.Tournaments.getById(
          match.tournamentId,
        ).then((tournament) => tournament?.coordinatorId);
        final User? coordinator = await DB.Coordinators.getByCoordinatorId(
          coordinatorId ?? -1,
        );
        setState(() {
          _homeTeam = homeTeam;
          _awayTeam = awayTeam;
          _scheduledStart = match.scheduledStart;
          _coordinator = coordinator;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Titolo e campo
                    if (_isMatchBooking) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: ATLColors.darkBlue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tournament Match',
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
                          Icon(
                            Icons.group,
                            color: ATLColors.darkBlue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lobby Booking',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ATLColors.title,
                                  ),
                                ),
                                Text(
                                  _field!.name,
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
                                  'Private Booking',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ATLColors.title,
                                  ),
                                ),
                                Text(
                                  _field!.name,
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
                          _buildTeam(_homeTeam),
                          Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.subtext,
                            ),
                          ),
                          _buildTeam(_awayTeam),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                    ],

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
                        Icon(
                          Icons.access_time,
                          color: ATLColors.darkBlue,
                          size: 20,
                        ),
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
                          Icon(
                            Icons.person,
                            color: ATLColors.darkBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Coordinator: ${_coordinator?.username ?? 'N/A'} (${_coordinator?.name ?? ''} ${_coordinator?.surname ?? ''})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ATLColors.title,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_scheduledStart != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: ATLColors.darkBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Scheduled: ${dateFormat.format(_scheduledStart!)} ${timeFormat.format(_scheduledStart!)}',
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

                    // Per lobby: owner e partecipanti
                    if (_isLobbyBooking) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: ATLColors.darkBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Owner: ${_owner?.username ?? 'N/A'} (${_owner?.name ?? ''} ${_owner?.surname ?? ''})',
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
                          Icon(
                            Icons.group,
                            color: ATLColors.darkBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_playersFound ?? 0}/${_maxPlayers ?? 0}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: (_playersFound ?? 0) >= (_maxPlayers ?? 0)
                                  ? Colors.red
                                  : ATLColors.title,
                            ),
                          ),
                          if ((_playersFound ?? 0) >= (_maxPlayers ?? 0)) ...[
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

                    // Per private: player
                    if (_isPrivateBooking) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: ATLColors.darkBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Player: ${_player?.username ?? 'N/A'} (${_player?.name ?? ''} ${_player?.surname ?? ''})',
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
              ),
            ],
          ),
        );
      },
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
          team?.name ?? 'TBD',
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
