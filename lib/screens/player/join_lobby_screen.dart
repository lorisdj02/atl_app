import 'package:atl_app/database/services/booking_service.dart';
import 'package:atl_app/database/services/payment_service.dart';
import 'package:atl_app/database/responses/join_lobby_response.dart';
import 'package:atl_app/models/checkout_payload.dart';
import 'package:flutter/material.dart';
import '../shop/checkout_screen.dart';
import 'package:provider/provider.dart';
import '../../models/lobby_booking.dart';
import '../../models/enums/sport_category.dart';
import '../../models/city.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/booking_widget.dart';
import '../../models/field.dart';
import '../../models/checkout_session.dart';
import '../../models/enums/checkout_type.dart';

class JoinLobbyScreen extends StatefulWidget {
  final SportCategory sportCategory;

  const JoinLobbyScreen({super.key, required this.sportCategory});

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  // Filters
  int? _selectedTotalPlayers;
  double? _selectedCity;
  DateTime? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _maxPlayersToPay;

  List<LobbyBooking> _availableLobbies = [];
  bool _isLoading = false;

  Map<double, Field> _fieldsCache = {};
  Map<double, String> _completeAddressPerField = {};
  Map<double, String> _usernamePerBooking = {};
  Map<double, int> _playersPaidPerBooking = {};

  final List<int> _availablePlayerCounts = [10, 14, 16, 18, 22];
  List<City> _availableCities = [];

  @override
  void initState() {
    super.initState();
    _loadLobbies();
  }

  Future<void> _loadLobbies() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<AccountProvider>(context, listen: false);
      final playerId = userProvider.activeRoleId!;

      DateTime? startDateTime;
      DateTime? endDateTime;

      if (_selectedDay != null) {
        if (_startTime != null && _endTime != null) {
          startDateTime = DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
            _startTime!.hour,
            _startTime!.minute,
          );
          endDateTime = DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
            _endTime!.hour,
            _endTime!.minute,
          );
        } else {
          // Default to whole day
          startDateTime = DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
            0,
            0,
          );
          endDateTime = DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
            23,
            59,
          );
        }
      }

      final JoinLobbyResponse data = await BookingService.getJoinLobbyScreen(
        sportCategory: widget.sportCategory,
        totalPlayers: _selectedTotalPlayers,
        selectedCityId: _selectedCity?.toDouble(),
        startTime: startDateTime,
        finishTime: endDateTime,
      );

      List<LobbyBooking> lobbies = data.lobbies;

      // Filter out lobbies where current user is the owner
      lobbies = lobbies
          .where((lobby) => lobby.ownerPlayerId != playerId)
          .toList();

      // Additional filter for playersToPay
      if (_maxPlayersToPay != null) {
        lobbies = lobbies
            .where((lobby) => lobby.playersToFind <= _maxPlayersToPay!)
            .toList();
      }

      setState(() {
        _availableLobbies = lobbies;
        _fieldsCache = data.fieldsCache;
        _completeAddressPerField = data.completeAddressPerField;
        _usernamePerBooking = data.usernamePerBooking;
        _playersPaidPerBooking = data.playersPaidPerBooking;
        _availableCities = data.cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingLobbies(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: ATLColors.darkBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        // Reset times when day changes
        _startTime = null;
        _endTime = null;
      });
      _loadLobbies();
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final l10n = AppLocalizations.of(context);
    if (_selectedDay == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectDayFirst)));
      return;
    }

    final List<TimeOfDay> timeSlots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute in [0, 15, 30, 45]) {
        final time = TimeOfDay(hour: hour, minute: minute);

        if (!isStartTime && _startTime != null) {
          final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
          final timeMinutes = time.hour * 60 + time.minute;
          if (timeMinutes <= startMinutes) continue;
        }

        timeSlots.add(time);
      }
    }

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isStartTime ? l10n.startTimeLabel : l10n.endTimeLabel,
            style: TextStyle(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                final timeString =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                return ListTile(
                  title: Text(timeString, style: const TextStyle(fontSize: 18)),
                  onTap: () => Navigator.of(context).pop(time),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _loadLobbies();
    }
  }

  void _showJoinDialog(LobbyBooking lobby) {
    final l10n = AppLocalizations.of(context);
    int selectedPlayers = 1;
    final maxPlayers = lobby.playersToFind;

    // Se c'è solo 1 spot disponibile, conferma direttamente senza slider
    if (maxPlayers == 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            l10n.joinLobby,
            style: TextStyle(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.onlyOneSpotLeft,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ATLColors.getPrimaryColor(
                    widget.sportCategory,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalFeeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '€${lobby.feePerPlayer.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.getPrimaryColor(widget.sportCategory),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelText),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _joinLobby(lobby, 1);
              },
              icon: const Icon(Icons.attach_money),
              label: Text(l10n.join),
              style: ElevatedButton.styleFrom(
                backgroundColor: ATLColors.getPrimaryColor(
                  widget.sportCategory,
                ),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final fee = lobby.feePerPlayer * selectedPlayers;

          return AlertDialog(
            title: Text(
              l10n.joinLobby,
              style: TextStyle(
                color: ATLColors.getPrimaryColor(widget.sportCategory),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.howManyPlayersPayingFor,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.players}:',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$selectedPlayers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.getPrimaryColor(widget.sportCategory),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: selectedPlayers.toDouble(),
                  min: 1,
                  max: maxPlayers.toDouble(),
                  divisions: maxPlayers > 1 ? maxPlayers - 1 : 1,
                  activeColor: ATLColors.getPrimaryColor(widget.sportCategory),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPlayers = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ATLColors.getPrimaryColor(
                      widget.sportCategory,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalFeeLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '€${fee.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ATLColors.getPrimaryColor(
                            widget.sportCategory,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelText),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _joinLobby(lobby, selectedPlayers);
                },
                icon: const Icon(Icons.attach_money),
                label: Text(l10n.join),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(
                    widget.sportCategory,
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _joinLobby(LobbyBooking lobby, int playersPaid) async {
    CheckoutPayload checkoutPayload = CheckoutPayload(
      lobbyId: lobby.id,
      playersPaid: playersPaid,
      amount: lobby.feePerPlayer * playersPaid,
      checkoutType: CheckoutType.lobbyBookingParticipate,
    );

    final CheckoutSession checkoutSession =
        await PaymentService.createCheckoutSession(checkoutPayload);
    bool? result = false;
    if (mounted) {
      result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            sportCategory: widget.sportCategory,
            sessionId: checkoutSession.id,
          ),
        ),
      );
    }

    if (result == true && mounted) {
      // TODO: handle post-payment transition
      _loadLobbies();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTotalPlayers = null;
      _selectedCity = null;
      _selectedDay = null;
      _startTime = null;
      _endTime = null;
      _maxPlayersToPay = null;
    });
    _loadLobbies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.joinLobby,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        hint: l10n.players,
                        value: _selectedTotalPlayers,
                        items: _availablePlayerCounts,
                        onChanged: (value) {
                          setState(() => _selectedTotalPlayers = value);
                          _loadLobbies();
                        },
                        displayText: (val) => '$val',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown<double>(
                        hint: l10n.cityHint,
                        value: _selectedCity,
                        items: _availableCities.map((c) => c.id).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCity = value);
                          _loadLobbies();
                        },
                        displayText: (val) {
                          final city = _availableCities.firstWhere(
                            (c) => c.id == val,
                            orElse: () => City(id: 0, name: ''),
                          );
                          return city.name;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: ATLColors.getPrimaryColor(
                                  widget.sportCategory,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDay == null
                                    ? l10n.dayShort
                                    : '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedDay == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown(
                        hint: l10n.maxPay,
                        value: _maxPlayersToPay,
                        items: List.generate(21, (i) => i + 1),
                        onChanged: (value) {
                          setState(() => _maxPlayersToPay = value);
                          _loadLobbies();
                        },
                        displayText: (val) => '$val',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: ATLColors.getPrimaryColor(
                                  widget.sportCategory,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _startTime == null
                                    ? l10n.startShort
                                    : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _startTime == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: ATLColors.getPrimaryColor(
                                  widget.sportCategory,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _endTime == null
                                    ? l10n.endShort
                                    : '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _endTime == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: Text(l10n.clearFilters),
                  style: TextButton.styleFrom(
                    foregroundColor: ATLColors.getPrimaryColor(
                      widget.sportCategory,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lobbies list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _availableLobbies.isEmpty
                ? Center(
                    child: Text(
                      l10n.noLobbiesAvailable,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableLobbies.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final lobby = _availableLobbies[index];

                      return Column(
                        children: [
                          BookingWidget(
                            playersPaid: _playersPaidPerBooking[lobby.id] ?? 0,
                            field: _fieldsCache[lobby.fieldId]!,
                            startTime: lobby.startTime,
                            finishTime: lobby.finishTime,
                            ownerUsername: _usernamePerBooking[lobby.id],
                            currentSport: widget.sportCategory,
                            booking: lobby,
                            isDeletable: false,
                            completeAddress:
                                _completeAddressPerField[lobby.fieldId]!,
                          ),
                          const SizedBox(height: 12),
                          if (_playersPaidPerBooking[lobby.id] == 0)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showJoinDialog(lobby),
                                icon: const Icon(Icons.add_circle),
                                label: Text(
                                  l10n.joinSpotsLeft(lobby.playersToFind),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ATLColors.getPrimaryColor(
                                    widget.sportCategory,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                displayText(item),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
