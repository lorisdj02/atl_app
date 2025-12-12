import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/field.dart';
import '../../models/lobby_booking.dart';
import '../../models/private_bookings.dart';
import '../../models/booking_status.dart';
import '../../database/db_controller.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/atl_step_indicator.dart';
import '../../models/sport_category.dart';


//TODO: Ci deve essere il pagamento alla fine della prenotazione e l'inserimento nella home page del player insieme ai tornei
enum BookingType { none, private, lobby }

class BookFieldScreen extends StatefulWidget {
  final SportCategory sportCategory;
  
  const BookFieldScreen({
    super.key,
    required this.sportCategory,
  });

  @override
  State<BookFieldScreen> createState() => _BookFieldScreenState();
}

class _BookFieldScreenState extends State<BookFieldScreen> {
  int _currentStep = 1; // 1, 2, 3, 4
  BookingType _selectedBookingType = BookingType.none;
  
  // Step 2 - Data input
  String? _selectedCity;
  Field? _selectedField;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  // Lobby specific
  int _maxPlayers = 10;
  int _ownerPaysFor = 1;
  
  bool _isLoading = false;
  List<Field> _availableFields = [];

  @override
  void dispose() {
    super.dispose();
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
        _currentStep--;
      });
    }
  }

  bool _canProceedFromStep2() {
    if (_selectedCity == null || _selectedDate == null || 
        _startTime == null || _endTime == null) {
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
    if (_selectedCity == null || _selectedDate == null || 
        _startTime == null || _endTime == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get all fields in the selected city
      final allFields = await DB.Fields.getByMaxPlayersAndCity(_maxPlayers, _selectedCity!);
      
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
    if (_selectedField == null || _startTime == null || _endTime == null) return 0.0;
    
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ATLColors.darkBlue,
            ),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ATLColors.darkBlue,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    
    if (picked != null) {
      // Round to nearest 15-minute interval
      final minutes = (picked.minute / 15).round() * 15;
      final roundedTime = TimeOfDay(
        hour: minutes == 60 ? picked.hour + 1 : picked.hour,
        minute: minutes == 60 ? 0 : minutes,
      );
      
      setState(() {
        if (isStartTime) {
          _startTime = roundedTime;
          // Validate that end time is at least 1 hour after start
          if (_endTime != null) {
            final startMinutes = roundedTime.hour * 60 + roundedTime.minute;
            final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
            if (endMinutes - startMinutes < 60) {
              _endTime = null; // Reset end time if invalid
            }
          }
        } else {
          // Validate that end time is at least 1 hour after start
          if (_startTime != null) {
            final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
            final endMinutes = roundedTime.hour * 60 + roundedTime.minute;
            if (endMinutes - startMinutes >= 60) {
              _endTime = roundedTime;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La prenotazione deve durare almeno 1 ora'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            _endTime = roundedTime;
          }
        }
      });
    }
  }

  Future<void> _createBooking() async {
    setState(() => _isLoading = true);

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
        
        await DB.PrivateBookings.create(newBooking);
      } else {
        final baseCost = _selectedField!.costTournament;
        final feePerPlayer = (baseCost / _maxPlayers).round();
        final playerToFind = _maxPlayers - _ownerPaysFor;
        
        final newBooking = LobbyBooking(
          id: DateTime.now().millisecondsSinceEpoch,
          fieldId: _selectedField!.id,
          ownerId: userProvider.activeRoleId!,
          maxPlayers: _maxPlayers,
          playerToFind: playerToFind,
          feePerPlayer: feePerPlayer,
          startTime: startDateTime,
          finishTime: endDateTime,
          status: BookingStatus.booked,
        );
        
        await DB.LobbyBookings.create(newBooking);
      }

      if (mounted) {
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
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
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
                    activeColor: ATLColors.getPrimaryColor(widget.sportCategory),
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
          description: 'Paghi tutto tu, è una prenotazione privata solo per te e i tuoi amici.',
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
          description: 'Crea una lobby e dividi il costo con altri giocatori. Decidi quanti giocatori partecipano e quanti ne paghi tu.',
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
        ElevatedButton(
          onPressed: _selectedBookingType != BookingType.none ? _goToNextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          child: DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Seleziona città *',
            ),
            items: ['Milano', 'Roma', 'Taranto'].map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
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
                Icon(Icons.calendar_today, color: ATLColors.getPrimaryColor(widget.sportCategory)),
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
                Icon(Icons.access_time, color: ATLColors.getPrimaryColor(widget.sportCategory)),
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
                Icon(Icons.access_time, color: ATLColors.getPrimaryColor(widget.sportCategory)),
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
          
          // Max Players Slider
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
                      'Numero massimo giocatori',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$_maxPlayers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.getPrimaryColor(widget.sportCategory),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxPlayers.toDouble(),
                  min: 2,
                  max: widget.sportCategory.maxPlayers.toDouble(),
                  divisions: 20,
                  activeColor: ATLColors.getPrimaryColor(widget.sportCategory),
                  onChanged: (value) {
                    setState(() {
                      _maxPlayers = value.toInt();
                      if (_ownerPaysFor > _maxPlayers) {
                        _ownerPaysFor = _maxPlayers;
                      }
                    });
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 32),
        
        // Continue button
        ElevatedButton(
          onPressed: _canProceedFromStep2() ? _goToNextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedField = field;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? ATLColors.getPrimaryColor(widget.sportCategory) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? ATLColors.getPrimaryColor(widget.sportCategory) : Colors.grey,
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
                            Text(
                              field.city,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Max ${field.maxPlayers} giocatori',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            () {
                              if (_startTime == null || _endTime == null) return '€0.00';
                              
                              final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
                              final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
                              final durationHours = (endMinutes - startMinutes) / 60.0;
                              final cost = field.hourlyCostPrivate * durationHours;
                              
                              return _selectedBookingType == BookingType.private
                                  ? '€${cost.toStringAsFixed(2)}'
                                  : '€${(cost / _maxPlayers).toStringAsFixed(2)}';
                            }(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.getPrimaryColor(widget.sportCategory),
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
                ),
              );
            },
          ),
        ],
        
        const SizedBox(height: 32),
        
        // Continue button
        ElevatedButton(
          onPressed: _selectedField != null ? _goToNextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    final totalCost = _calculateCost();
    
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
              _SummaryRow(
                label: 'Campo',
                value: _selectedField?.name ?? '',
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Città',
                value: _selectedCity ?? '',
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Data',
                value: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Orario',
                value: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} - ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
              ),
              
              if (_selectedBookingType == BookingType.lobby) ...[
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Giocatori totali',
                  value: '$_maxPlayers',
                ),
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
        ElevatedButton(
          onPressed: _createBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Conferma Prenotazione',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Back button
        OutlinedButton(
          onPressed: _goToPreviousStep,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: ATLColors.getPrimaryColor(widget.sportCategory)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Indietro',
            style: TextStyle(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
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
            color: isHighlighted ? (highlightColor ?? ATLColors.darkBlue) : Colors.black,
          ),
        ),
      ],
    );
  }
}
