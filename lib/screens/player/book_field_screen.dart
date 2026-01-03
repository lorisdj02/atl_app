import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/field.dart';
import '../../models/city.dart';
import '../../models/lobby_booking.dart';
import '../../models/private_bookings.dart';
import '../../models/booking_status.dart';
import '../../database/db_controller.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/atl_step_indicator.dart';
import '../../widgets/field_size_alert_dialog.dart';
import '../../models/sport_category.dart';

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
  List<Field> _availableFields = [];
  List<City> _availableCities = [];

  // Available player counts
  final List<int> _availablePlayerCounts = [];

  String _getSportDisplayName(int maxPlayers) {
    final playersPerSide = maxPlayers ~/ 2;
    final sportName = widget.sportCategory.name.toUpperCase();
    return '$sportName ${playersPerSide}v$playersPerSide';
  }

  bool _isFieldOversized(Field field) {
    // Mostra warning solo per le lobby, non per le prenotazioni private
    if (_selectedBookingType != BookingType.lobby) return false;
    // _maxPlayers è il numero totale di giocatori, quindi minPlayers = _maxPlayers
    return _maxPlayers < field.maxPlayers;
  }

  Future<void> _showOversizedFieldWarning(Field field) async {
    return showDialog(
      context: context,
      builder: (context) => FieldSizeAlertDialog(
        field: field,
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
      final cities = await DB.Cities.getAll();
      setState(() {
        _availableCities = cities;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento delle città: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToNextStep() {
    if (_currentStep == 1 && _selectedBookingType == BookingType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona un tipo di prenotazione'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 2 && !_canProceedFromStep2()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compila tutti i campi obbligatori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 3 && _selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona un campo'),
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
      // Get all fields in the selected city
      final allFields = await DB.Fields.getByMaxPlayersAndCity(
        _maxPlayers,
        _selectedCity!,
      );

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

      // Get free field IDs
      final allFieldIds = allFields.map((f) => f.id).toList();
      final freeFieldIds = await DB.LobbyBookings.getFreeFieldIds(
        startDateTime,
        endDateTime,
        allFieldIds,
      );

      // Filter available fields
      setState(() {
        _availableFields = allFields
            .where((field) => freeFieldIds?.contains(field.id) ?? false)
            .where((field) => field.isOpenAt(startDateTime))
            .where((field) => field.isOpenAt(endDateTime))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento dei campi: $e'),
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
    final city = await DB.Cities.getById(_selectedCity!);
    return city?.name ?? '';
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

  Future<void> _selectTime(bool isStartTime) async {
    // Check if date is selected first
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona prima una data'),
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

    for (int hour = 0; hour < 24; hour++) {
      for (int minute in [0, 15, 30, 45]) {
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
            isStartTime ? 'Seleziona ora inizio' : 'Seleziona ora fine',
            style: TextStyle(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: timeSlots.isEmpty
                ? const Center(
                    child: Text(
                      'Nessun orario disponibile',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
                'Annulla',
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
    setState(() => _isLoading = true);
    bool success = false;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.activeUser;

      if (currentUser == null) {
        throw Exception('User not found');
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

      if (_selectedBookingType == BookingType.private) {
        final newBooking = PrivateBooking(
          id: DateTime.now().millisecondsSinceEpoch,
          fieldId: _selectedField!.id,
          playerId: userProvider.activeRoleId!,
          startTime: startDateTime,
          finishTime: endDateTime,
          status: BookingStatus.booked,
        );

        success = await DB.PrivateBookings.addPrivateBooking(
          newBooking.playerId,
          newBooking.fieldId,
          newBooking.startTime,
          newBooking.finishTime,
          newBooking.status,
        );
      } else {
        final baseCost = _selectedField!.costTournament;
        final double feePerPlayer = (baseCost / _maxPlayers * 100).ceil() / 100;
        final playerToFind = _maxPlayers - _ownerPaysFor;

        final newBooking = LobbyBooking(
          id: 0, // ID will be set by the database
          fieldId: _selectedField!.id,
          ownerId: userProvider.activeRoleId!,
          maxPlayers: _maxPlayers,
          playerToFind: playerToFind,
          feePerPlayer: feePerPlayer,
          startTime: startDateTime,
          finishTime: endDateTime,
          status: BookingStatus.booked,
        );

        success = await DB().createLobby(
          newBooking.fieldId,
          newBooking.ownerId,
          newBooking.maxPlayers,
          newBooking.playerToFind,
          newBooking.feePerPlayer,
          newBooking.startTime,
          newBooking.finishTime,
        );
      }

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenotazione creata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // <-- MODIFICATO: ritorna true
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text(
          'Prenota Campo',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Seleziona il tipo di prenotazione',
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
          title: 'Prenotazione Privata',
          description:
              'Paghi tutto tu, è una prenotazione privata solo per te e i tuoi amici.',
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
          title: 'Lobby Pubblica',
          description:
              'Crea una lobby e dividi il costo con altri giocatori. Decidi quanti giocatori partecipano e quanti ne paghi tu.',
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
          text: 'Continua',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Inserisci i dati della prenotazione',
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Seleziona città *',
            ),
            items: _availableCities.map((city) {
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
                      ? 'Seleziona data *'
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
          onTap: () => _selectTime(true),
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
                      ? 'Ora inizio *'
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
          onTap: () => _selectTime(false),
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
                      ? 'Ora fine *'
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
            'Configurazione Lobby',
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
                const Text(
                  'Numero massimo giocatori',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                    const Text(
                      'Quanti giocatori paghi tu',
                      style: TextStyle(
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
                  'Giocatori da trovare: ${_maxPlayers - _ownerPaysFor}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Continue button
        ATLButton(
          text: 'Continua',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Seleziona il campo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        if (_availableFields.isEmpty) ...[
          const Center(
            child: Text(
              'Nessun campo disponibile per questa fascia oraria',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
            child: const Center(
              child: Text(
                'TODO: Mappa dei campi disponibili',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Available fields list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableFields.length,
            itemBuilder: (context, index) {
              final field = _availableFields[index];
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
                                  'Questo campo è per ${_getSportDisplayName(field.maxPlayers)}',
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
                                    ? 'Totale'
                                    : 'Per giocatore',
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
                                  'Campo più grande del necessario - costo maggiore',
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
          text: 'Continua',
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
    final totalCost = _calculateCost();
    final totalToPay = _calculateTotalToPay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Riepilogo Prenotazione',
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
                label: 'Tipo',
                value: _selectedBookingType == BookingType.private
                    ? 'Prenotazione Privata'
                    : 'Lobby Pubblica',
              ),
              const Divider(height: 24),
              _SummaryRow(label: 'Campo', value: _selectedField?.name ?? ''),
              const Divider(height: 24),
              FutureBuilder<String>(
                future: _getCityName(),
                builder: (context, snapshot) {
                  return _SummaryRow(
                    label: 'Città',
                    value: snapshot.data ?? 'Caricamento...',
                  );
                },
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Data',
                value:
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Orario',
                value:
                    '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} - ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
              ),

              if (_selectedBookingType == BookingType.lobby) ...[
                const Divider(height: 24),
                _SummaryRow(label: 'Giocatori totali', value: '$_maxPlayers'),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Giocatori che paghi',
                  value: '$_ownerPaysFor',
                ),
              ],

              const Divider(height: 24),
              _SummaryRow(
                label: _selectedBookingType == BookingType.private
                    ? 'Costo Totale'
                    : 'Costo per Giocatore',
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
          text: 'Conferma Prenotazione - €${totalToPay.toStringAsFixed(2)}',
          onPressed: _createBooking,
          size: ATLButtonSize.large,
          isFilled: true,
          fullWidth: true,
          color: ATLColors.getPrimaryColor(widget.sportCategory),
        ),

        const SizedBox(height: 16),

        // Back button
        ATLButton(
          text: 'Indietro',
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
