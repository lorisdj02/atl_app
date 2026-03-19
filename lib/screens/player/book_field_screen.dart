import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/field.dart';
import '../../models/city.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/atl_step_indicator.dart';
import '../../widgets/field_size_alert_dialog.dart';
import '../../models/sport_category.dart';
import '../../database/db_write.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';
import '../shop/checkout_screen.dart';
import '../../models/checkout_session.dart';

import '../../database/responses/book_field_response.dart';

//TODO: Ci deve essere il pagamento alla fine della prenotazione e l'inserimento nella home page del player insieme ai tornei
enum BookingType { none, private, lobby }

class BookFieldScreen extends StatefulWidget {
  final SportCategory sportCategory;

  const BookFieldScreen({super.key, required this.sportCategory});

  @override
  State<BookFieldScreen> createState() => _BookFieldScreenState();
}

class _BookFieldScreenState extends State<BookFieldScreen> {
  int _currentStep = 1; // 1, 2, 3, 4
  BookingType _selectedBookingType = BookingType.none;

  // Step 2 - Data input
  int? _selectedCity; // cityId
  Field? _selectedField;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Lobby specific
  int _maxPlayers = 10;
  int _ownerPaysFor = 1;

  bool _isLoading = false;
  List<Field> _fields = [];
  List<City> _cities = [];
  Map<int, TimeOfDay> _minOpeningTimePerCity = {};
  Map<int, TimeOfDay> _maxClosingTimePerCity = {};

  // Available player counts
  final List<int> _availablePlayerCounts = [];
  Map<int, int> _maxPlayerPerField = {}; // fieldId -> maxPlayers

  String _getSportDisplayName(int maxPlayers) {
    final playersPerSide = maxPlayers ~/ 2;
    final sportName = widget.sportCategory.name.toUpperCase();
    return '$sportName ${playersPerSide}v$playersPerSide';
  }

  bool _isFieldOversized(Field field) {
    // Mostra warning solo per le lobby, non per le prenotazioni private
    if (_selectedBookingType != BookingType.lobby) return false;
    // _maxPlayers è il numero totale di giocatori, quindi minPlayers = _maxPlayers
    return _maxPlayers < _maxPlayerPerField[field.id]!;
  }

  Future<void> _showOversizedFieldWarning(Field field) async {
    return showDialog(
      context: context,
      builder: (context) => FieldSizeAlertDialog(
        field: field,
        maxPlayers: _maxPlayerPerField[field.id]!,
        onConfirm: () {
          setState(() {
            _selectedField = field;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.sportCategory == SportCategory.football) {
      _availablePlayerCounts.addAll([10, 14, 16, 18, 22]);
    }
    _loadCities();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final BookFieldResponse data = await DBRead.getBookFieldScreen();

      final preferredCityId = Provider.of<AccountProvider>(
        context,
        listen: false,
      ).cityId;
      setState(() {
        _cities = data.cities;
        _minOpeningTimePerCity = data.minOpeningTimePerCity;
        _maxClosingTimePerCity = data.maxClosingTimePerCity;
        if (preferredCityId != null &&
            _cities.any((c) => c.id == preferredCityId)) {
          _selectedCity = preferredCityId;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorLoadingCities(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToNextStep() {
    if (_currentStep == 1 && _selectedBookingType == BookingType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectBookingTypeFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 2 && !_canProceedFromStep2()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 3 && _selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectFieldFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });

      if (_currentStep == 3) {
        _loadAvailableFields();
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        // Reset field selection when going back from step 4
        if (_currentStep == 4) {
          _selectedField = null;
        }
        _currentStep--;
      });
    }
  }

  bool _canProceedFromStep2() {
    if (_selectedCity == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      return false;
    }

    // Validate minimum 1 hour booking
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes - startMinutes < 60) {
        return false;
      }
    }

    return true;
  }

  Future<void> _loadAvailableFields() async {
    if (_selectedCity == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create DateTime objects for the booking period
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final FieldsAndMaxPlayersPerFieldResponse data = await DBRead.getFreeFieldsByPlayerAndCityAndDate(
        maxPlayers: _maxPlayers,
        cityId: _selectedCity!,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        sportCategory: widget.sportCategory,
      );

      // Filter available fields
      setState(() {
        _fields = data.fields;
        _maxPlayerPerField = data.maxPlayersPerField;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingFields(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateCost() {
    if (_selectedField == null || _startTime == null || _endTime == null)
      return 0.0;

    // Calculate duration in hours (including fractions)
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final durationMinutes = endMinutes - startMinutes;
    final durationHours = durationMinutes / 60.0;

    // Calculate base cost (hourly rate * duration)
    final baseCost = _selectedField!.hourlyCostPrivate * durationHours;

    if (_selectedBookingType == BookingType.lobby) {
      return baseCost / _maxPlayers;
    }

    return baseCost;
  }

  // Nuovo metodo per calcolare il costo totale da pagare
  double _calculateTotalToPay() {
    if (_selectedField == null || _startTime == null || _endTime == null)
      return 0.0;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final durationMinutes = endMinutes - startMinutes;
    final durationHours = durationMinutes / 60.0;

    final baseCost = _selectedField!.hourlyCostPrivate * durationHours;

    if (_selectedBookingType == BookingType.lobby) {
      // Costo per giocatore * numero di giocatori che pago
      return (baseCost / _maxPlayers) * _ownerPaysFor;
    }

    return baseCost;
  }

  Future<String> _getCityName() async {
    if (_selectedCity == null) return '';
    return _cities.firstWhere((c) => c.id == _selectedCity).name;
  }

  Future<void> _selectDate() async {
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime, int cityId) async {
    // Check if date is selected first
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectDateFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate available time slots (every 15 minutes)
    final List<TimeOfDay> timeSlots = [];
    final now = DateTime.now();
    final isToday =
        _selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    final int minHour = _minOpeningTimePerCity[cityId]?.hour ?? 0;
    final int maxHour = _maxClosingTimePerCity[cityId]?.hour ?? 24;

    final int minMinute = _minOpeningTimePerCity[cityId]?.minute ?? 0;
    final int maxMinute = _maxClosingTimePerCity[cityId]?.minute ?? 0;

    for (
      int hour = (isStartTime ? minHour : minHour + 1);
      hour <= (isStartTime ? maxHour - 1 : maxHour);
      hour++
    ) {
      // -1 to ensure at least 1 hour booking
      for (int minute in [0, 15, 30, 45]) {
        if ((hour == maxHour - 1 && minute > maxMinute) ||
            (hour == minHour && minute < minMinute)) {
          continue; // Skip time slots that would end after closing time
        }
        final time = TimeOfDay(hour: hour, minute: minute);

        // Skip past times if selecting for today
        if (isStartTime && isToday) {
          final currentMinutes = now.hour * 60 + now.minute;
          final timeMinutes = time.hour * 60 + time.minute;
          if (timeMinutes <= currentMinutes) {
            continue; // Skip this time slot
          }
        }

        // Skip invalid end times (less than 1 hour from start or in the past)
        if (!isStartTime && _startTime != null) {
          final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
          final timeMinutes = time.hour * 60 + time.minute;

          // Must be at least 1 hour after start
          if (timeMinutes - startMinutes < 60) {
            continue;
          }

          // Skip past times if today
          if (isToday) {
            final currentMinutes = now.hour * 60 + now.minute;
            if (timeMinutes <= currentMinutes) {
              continue;
            }
          }
        }

        timeSlots.add(time);
      }
    }

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isStartTime
                ? AppLocalizations.of(context).startTimeLabel
                : AppLocalizations.of(context).endTimeLabel,
            style: TextStyle(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
                child: timeSlots.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).noTimeSlotsAvailable,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final timeString =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                      return ListTile(
                        title: Text(
                          timeString,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(time);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).cancelText,
                style: TextStyle(
                  color: ATLColors.getPrimaryColor(widget.sportCategory),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Validate that end time is at least 1 hour after start
          if (_endTime != null) {
            final startMinutes = picked.hour * 60 + picked.minute;
            final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
            if (endMinutes - startMinutes < 60) {
              _endTime = null; // Reset end time if invalid
            }
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _createBooking() async {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    if (userProvider.activeAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( 
          content: Text(l10n.userNotFound),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    final totalToPay = _calculateTotalToPay();

    if (_selectedBookingType == BookingType.private) {
      Map<String, dynamic> payload = {
        'playerId': userProvider.activeRoleId!,
        'fieldId': _selectedField!.id,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
      };

      final int sessionId = await DBWrite.createCheckoutSession(
        userId: userProvider.activeAccount!.id,
        payload: payload,
        amount: totalToPay,
        type: CheckoutType.privateBooking,
      );

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            sportCategory: widget.sportCategory,
            sessionId: sessionId,
          ),
        ),
      );

      if (result == true && mounted) {
        // TODO: handle post-payment transition
        Navigator.of(context).pop(true);
      }
    } else {
      final baseCost = _selectedField!.costTournament;
      final double feePerPlayer = (baseCost / _maxPlayers * 100).ceil() / 100;
      final playersToFind = _maxPlayers - _ownerPaysFor;

      Map<String, dynamic> payload = {
        'ownerPlayerId': userProvider.activeRoleId!,
        'fieldId': _selectedField!.id,
        'maxPlayers': _maxPlayers,
        'playersToFind': playersToFind,
        'feePerPlayer': feePerPlayer,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
      };

      // Ricorda che playersToPay = maxPlayers - playersToFind

      final int sessionId = await DBWrite.createCheckoutSession(
        userId: userProvider.activeAccount!.id,
        payload: payload,
        amount: totalToPay,
        type: CheckoutType.lobbyBookingCreate,
      );

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            sportCategory: widget.sportCategory,
            sessionId: sessionId,
          ),
        ),
      );

      if (result == true && mounted) {
        // TODO: handle post-payment transition
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 1) {
              _goToPreviousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context).bookAField,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Step indicator
                  ATLStepIndicator(
                    currentStep: _currentStep,
                    totalSteps: 4,
                    activeColor: ATLColors.getPrimaryColor(
                      widget.sportCategory,
                    ),
                    inactiveColor: ATLColors.darkBlue,
                  ),

                  const SizedBox(height: 30),

                  // Content
                  _buildCurrentStep(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.selectBookingType,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Private Booking Option
        _BookingTypeCard(
          title: l10n.privateBooking,
          description: l10n.privateBookingDesc,
          icon: Icons.lock_person,
          isSelected: _selectedBookingType == BookingType.private,
          categoryColor: ATLColors.getPrimaryColor(widget.sportCategory),
          onTap: () {
            setState(() {
              _selectedBookingType = BookingType.private;
            });
          },
        ),

        const SizedBox(height: 20),

        // Lobby Booking Option
        _BookingTypeCard(
          title: l10n.publicLobby,
          description: l10n.publicLobbyDesc,
          icon: Icons.groups,
          isSelected: _selectedBookingType == BookingType.lobby,
          categoryColor: ATLColors.getPrimaryColor(widget.sportCategory),
          onTap: () {
            setState(() {
              _selectedBookingType = BookingType.lobby;
            });
          },
        ),

        const SizedBox(height: 40),

        // Continue button
        ATLButton(
          text: l10n.continueStep,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
          onPressed: _selectedBookingType != BookingType.none
              ? _goToNextStep
              : () {},
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.insertBookingData,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // City Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedCity,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.selectCityRequired,
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city.id, child: Text(city.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedField = null;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        // Date Picker
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ATLColors.getPrimaryColor(widget.sportCategory),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? l10n.selectDateRequired
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Start Time Picker
        GestureDetector(
          onTap: () => _selectTime(true, _selectedCity!),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: ATLColors.getPrimaryColor(widget.sportCategory),
                ),
                const SizedBox(width: 12),
                Text(
                  _startTime == null
                      ? l10n.startTimeRequired
                      : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _startTime == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // End Time Picker
        GestureDetector(
          onTap: () => _selectTime(false, _selectedCity!),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: ATLColors.getPrimaryColor(widget.sportCategory),
                ),
                const SizedBox(width: 12),
                Text(
                  _endTime == null
                      ? l10n.endTimeRequired
                      : '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _endTime == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lobby specific fields
        if (_selectedBookingType == BookingType.lobby) ...[
          const SizedBox(height: 24),

          Text(
            l10n.lobbyConfiguration,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ATLColors.getPrimaryColor(widget.sportCategory),
            ),
          ),

          const SizedBox(height: 16),

          // Max Players Dropdown (instead of slider)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.maxPlayersLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                DropdownButton<int>(
                  value: _maxPlayers,
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.getPrimaryColor(widget.sportCategory),
                  ),
                  items: _availablePlayerCounts.map((count) {
                    return DropdownMenuItem(
                      value: count,
                      child: Text('$count'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _maxPlayers = value;
                        if (_ownerPaysFor > _maxPlayers) {
                          _ownerPaysFor = _maxPlayers;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Owner Pays For Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.playersPaidByOwner,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$_ownerPaysFor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.getPrimaryColor(widget.sportCategory),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _ownerPaysFor.toDouble(),
                  min: 1,
                  max: _maxPlayers.toDouble(),
                  divisions: _maxPlayers - 1,
                  activeColor: ATLColors.getPrimaryColor(widget.sportCategory),
                  onChanged: (value) {
                    setState(() {
                      _ownerPaysFor = value.toInt();
                    });
                  },
                ),
                Text(
                  l10n.playersToFind(_maxPlayers - _ownerPaysFor),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Continue button
        ATLButton(
          text: l10n.continueStep,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
          onPressed: _canProceedFromStep2() ? _goToNextStep : () {},
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.selectField,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        if (_fields.isEmpty) ...[
          Center(
            child: Text(
              l10n.noFieldsAvailable,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          // TODO: Implement map view here
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                l10n.availableFieldsMapTodo,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Available fields list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            itemBuilder: (context, index) {
              final field = _fields[index];
              final isSelected = _selectedField?.id == field.id;
              final isOversized = _isFieldOversized(field);

              return GestureDetector(
                onTap: () async {
                  if (isOversized) {
                    await _showOversizedFieldWarning(field);
                  } else {
                    setState(() {
                      _selectedField = field;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ATLColors.getPrimaryColor(widget.sportCategory)
                          : isOversized
                          ? Colors.orange
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? ATLColors.getPrimaryColor(
                                    widget.sportCategory,
                                  )
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.fieldForSport(
                                    _getSportDisplayName(
                                      _maxPlayerPerField[field.id]!,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                () {
                                  if (_startTime == null || _endTime == null)
                                    return '€0.00';

                                  final startMinutes =
                                      _startTime!.hour * 60 +
                                      _startTime!.minute;
                                  final endMinutes =
                                      _endTime!.hour * 60 + _endTime!.minute;
                                  final durationHours =
                                      (endMinutes - startMinutes) / 60.0;
                                  final cost =
                                      field.hourlyCostPrivate * durationHours;

                                  return _selectedBookingType ==
                                          BookingType.private
                                      ? '€${cost.toStringAsFixed(2)}'
                                      : '€${(cost / _maxPlayers).toStringAsFixed(2)}';
                                }(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ATLColors.getPrimaryColor(
                                    widget.sportCategory,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedBookingType == BookingType.private
                                    ? l10n.total
                                    : l10n.perPlayer,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isOversized) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.fieldTooLargeWarning,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 32),

        // Continue button
        ATLButton(
          text: l10n.continueStep,
          onPressed: _selectedField != null ? () => _goToNextStep() : () {},
          size: ATLButtonSize.large,
          isFilled: true,
          fullWidth: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    final l10n = AppLocalizations.of(context);
    final totalCost = _calculateCost();
    final totalToPay = _calculateTotalToPay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bookingSummary,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(
                label: AppLocalizations.of(context).labelType,
                value: _selectedBookingType == BookingType.private
                    ? AppLocalizations.of(context).privateBooking
                    : AppLocalizations.of(context).publicLobby,
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: AppLocalizations.of(context).labelField,
                value: _selectedField?.name ?? '',
              ),
              const Divider(height: 24),
              FutureBuilder<String>(
                future: _getCityName(),
                builder: (context, snapshot) {
                  return _SummaryRow(
                    label: AppLocalizations.of(context).labelCity,
                    value: snapshot.data ?? AppLocalizations.of(context).loading,
                  );
                },
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: AppLocalizations.of(context).labelDate,
                value:
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: AppLocalizations.of(context).labelSchedule,
                value:
                    '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} - ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
              ),

              if (_selectedBookingType == BookingType.lobby) ...[
                const Divider(height: 24),
                _SummaryRow(
                  label: AppLocalizations.of(context).labelTotalPlayers,
                  value: '$_maxPlayers',
                ),
                const Divider(height: 24),
                _SummaryRow(
                  label: AppLocalizations.of(context).labelPlayersPaid,
                  value: '$_ownerPaysFor',
                ),
              ],

              const Divider(height: 24),
              _SummaryRow(
                label: _selectedBookingType == BookingType.private
                    ? AppLocalizations.of(context).totalCost
                    : AppLocalizations.of(context).costPerPlayer,
                value: '€${totalCost.toStringAsFixed(2)}',
                isHighlighted: true,
                highlightColor: ATLColors.getPrimaryColor(widget.sportCategory),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Confirm button
        ATLButton(
          text: AppLocalizations.of(context).confirmBooking(
            '€${totalToPay.toStringAsFixed(2)}',
          ),
          onPressed: _createBooking,
          size: ATLButtonSize.large,
          isFilled: true,
          fullWidth: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
        ),

        const SizedBox(height: 16),

        // Back button
        ATLButton(
          text: AppLocalizations.of(context).back,
          onPressed: _goToPreviousStep,
          size: ATLButtonSize.large,
          isFilled: false,
          fullWidth: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
        ),
      ],
    );
  }
}

// Booking Type Card Widget
class _BookingTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final Color categoryColor;
  final VoidCallback onTap;

  const _BookingTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? categoryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? categoryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? categoryColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? categoryColor : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? categoryColor : Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? highlightColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? (highlightColor ?? ATLColors.darkBlue)
                : Colors.black,
          ),
        ),
      ],
    );
  }
}
