import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/sport.dart';
import '../../models/field.dart';
import '../../models/sport_category.dart';
import '../../models/tournament.dart';
import '../../database/db_controller.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_step_indicator.dart';
import '../../widgets/sport_selector_widget.dart';
import '../../widgets/info_row_widget.dart';

enum Round2Option {
  none,
  groupStageOnly,
  finalStageOnly,
  both;

  String get displayName {
    switch (this) {
      case Round2Option.none:
        return 'No';
      case Round2Option.groupStageOnly:
        return 'Solo ai gironi';
      case Round2Option.finalStageOnly:
        return 'Solo nella fase finale';
      case Round2Option.both:
        return 'Per tutto il torneo';
    }
  }
}

class CreateTournamentScreen extends StatefulWidget {
  final SportCategory currentSport;

  const CreateTournamentScreen({super.key, required this.currentSport});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  int _currentStep =
      0; // 0: sport, 1: logistics, 2: details, 3: field, 4: description, 5: summary

  // Step 0 - Sport selection
  Sport? _selectedSport;

  // Step 1 - Logistic details
  bool _prize1 = true;
  bool _prize2 = false;
  String? _selectedCity;
  bool _isPublic = true;
  bool _hasProfit = true;
  String? _selectedMonth; // "now" or "YYYY-MM"

  // Step 2 - Tournament details
  int _numTeams = 8;
  int? _numGroups;
  Round2Option _round2Option = Round2Option.none;
  int? _qualified;

  // Step 3 - Field selection
  Field? _selectedField;

  // Step 4 - Description
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  List<Field> _availableFields = [];

  // Available options
  final List<String> _cities = ['Milano', 'Taranto', 'Roma'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    // Validation for each step
    if (_currentStep == 0 && _selectedSport == null) {
      _showError('Seleziona uno sport per continuare');
      return;
    }

    if (_currentStep == 1 && !_canProceedFromStep1()) {
      _showError('Compila tutti i campi obbligatori');
      return;
    }

    if (_currentStep == 2 && !_canProceedFromStep2()) {
      _showError('Completa tutti i dettagli del torneo');
      return;
    }

    if (_currentStep == 3 && _selectedField == null) {
      _showError('Seleziona un campo per continuare');
      return;
    }

    if (_currentStep == 4 && !_canProceedFromStep4()) {
      _showError('Inserisci nome e descrizione del torneo');
      return;
    }

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });

      if (_currentStep == 3) {
        _loadAvailableFields();
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        if (_currentStep == 4) {
          _selectedField = null;
        }
        _currentStep--;
      });
    }
  }

  bool _canProceedFromStep1() {
    return _selectedCity != null && _selectedMonth != null;
  }

  bool _canProceedFromStep2() {
    return _numGroups != null && _qualified != null;
  }

  bool _canProceedFromStep4() {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _loadAvailableFields() async {
    if (_selectedCity == null || _selectedSport == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final allFields = await DB.Fields.getByMaxPlayersAndCity(
        _selectedSport!.maxPlayersPerTeam,
        _selectedCity!,
      );

      setState(() {
        _availableFields = allFields;
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

  List<int> _getValidGroupCounts() {
    List<int> validGroups = [];
    for (int g = 2; g <= _numTeams; g++) {
      if (_numTeams % g == 0 && (_numTeams / g) >= 3) {
        validGroups.add(g);
      }
    }
    return validGroups;
  }

  List<int> _getValidQualifiedCounts() {
    if (_numGroups == null) return [];

    List<int> validCounts = [];

    // Find the next power of 2 >= numGroups
    int minQualified = 1;
    while (minQualified < _numGroups!) {
      minQualified *= 2;
    }

    // Add all valid powers of 2 less than numTeams
    int current = minQualified;
    while (current < _numTeams) {
      validCounts.add(current);
      current *= 2;
    }

    return validCounts;
  }

  Tournament _createFictitiousTournament() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if(userProvider.activeUser == null ||
        userProvider.activeRoleId == null ||
        userProvider.isCoordinator == false) {
      throw Exception('Coordinator not found');
    }

    // Parse start date
    DateTime? startDate;
    if (_selectedMonth != null && _selectedMonth != 'Appena possibile') {
      final parts = _selectedMonth!.split(' ');
      final monthName = parts[0];
      final year = int.parse(parts[1]);
      final month = _getMonthNumber(monthName);
      startDate = DateTime(year, month, 1);
    }

    return Tournament(
      id: 0,
      name: _nameController.text.trim(),
      coordinatorId: userProvider.activeRoleId!,
      fieldId: _selectedField!.id,
      city: _selectedCity!,
      startDate: startDate,
      sportId: _getSportId(),
      numTeams: _numTeams,
      paidTeams: 0,
      numGroups: _numGroups!,
      round2GroupStage:
          _round2Option == Round2Option.groupStageOnly ||
          _round2Option == Round2Option.both,
      round2FinalStage:
          _round2Option == Round2Option.finalStageOnly ||
          _round2Option == Round2Option.both,
      qualified: _qualified!,
      description: _descriptionController.text.trim(),
      payCoordinator: 0,
      fee: 0,
      prize1: 0,
      prize2: 0,
      isPublic: _isPublic
    );
  }

  List<String> _getAvailableMonths() {
    List<String> months = ['Appena possibile'];
    final now = DateTime.now();

    // Add current month and next 2 months
    for (int i = 0; i < 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      final monthName = _getMonthName(date.month);
      final year = date.year;
      months.add('$monthName $year');
    }

    return months;
  }

  String _getMonthName(int month) {
    const months = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    return months[month - 1];
  }

  Future<void> _createTournament() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.activeUser;

      if (currentUser == null ||
          userProvider.activeRoleId == null ||
          userProvider.isCoordinator == false) {
        throw Exception('Coordinator not found');
      }

      // Parse round2 options
      final round2GroupStage =
          _round2Option == Round2Option.groupStageOnly ||
          _round2Option == Round2Option.both;
      final round2FinalStage =
          _round2Option == Round2Option.finalStageOnly ||
          _round2Option == Round2Option.both;

      // Parse start date
      DateTime? startDate;
      if (_selectedMonth != null && _selectedMonth != 'Appena possibile') {
        final parts = _selectedMonth!.split(' ');
        final monthName = parts[0];
        final year = int.parse(parts[1]);
        final month = _getMonthNumber(monthName);
        startDate = DateTime(year, month, 1);
      }

      final success = await DB.Tournaments.newTournament(
        name: _nameController.text.trim(),
        coordinatorId: userProvider.activeRoleId!,
        fieldId: _selectedField!.id,
        city: _selectedCity!,
        startDate: startDate,
        sportId: _getSportId(),
        numTeams: _numTeams,
        numGroups: _numGroups!,
        round2GroupStage: round2GroupStage,
        round2FinalStage: round2FinalStage,
        qualified: _qualified!,
        description: _descriptionController.text.trim(),
        payCoordinator: _hasProfit,
        prize1: _prize1,
        prize2: _prize2,
        isPublic: _isPublic,
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Torneo creato con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella creazione del torneo: $e'),
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

  int _getMonthNumber(String monthName) {
    const months = {
      'Gennaio': 1,
      'Febbraio': 2,
      'Marzo': 3,
      'Aprile': 4,
      'Maggio': 5,
      'Giugno': 6,
      'Luglio': 7,
      'Agosto': 8,
      'Settembre': 9,
      'Ottobre': 10,
      'Novembre': 11,
      'Dicembre': 12,
    };
    return months[monthName] ?? 1;
  }

  int _getSportId() {
    return _selectedSport!.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              _goToPreviousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Crea Torneo',
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
          : Column(
              children: [
                if (_currentStep > 0 && _selectedSport != null)
                  Container(
                    color: ATLColors.getPrimaryColor(widget.currentSport),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ATLStepIndicator(
                      currentStep: _currentStep,
                      totalSteps: 5,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildCurrentStep(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return FutureBuilder<Widget>(
          future: _buildStep5(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Errore nel caricamento: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return snapshot.data ?? const SizedBox.shrink();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep0() {
    return Column(
      children: [
        SportSelectorWidget(
          sportCategory: widget.currentSport,
          selectedSport: _selectedSport,
          onSportSelected: (sport) {
            setState(() {
              _selectedSport = sport;
            });
          },
          title: 'Seleziona lo sport',
          subtitle: 'Scegli la categoria sportiva per il tuo torneo',
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dettagli logistici',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Prize 1
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Premio 1° posto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _prize1,
                onChanged: _hasProfit
                    ? null
                    : (value) {
                        setState(() {
                          _prize1 = value;
                          if (!value) {
                            _prize2 = false;
                          }
                        });
                      },
                activeColor: ATLColors.getPrimaryColor(widget.currentSport),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Prize 2
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Premio 2° posto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _prize2,
                onChanged: _prize1
                    ? (value) {
                        setState(() {
                          _prize2 = value;
                        });
                      }
                    : null,
                activeColor: ATLColors.getPrimaryColor(widget.currentSport),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // City Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCity,
              hint: const Text('Città'),
              items: _cities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  _selectedField = null;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Visibility
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visibilità',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Pubblico')),
                  ButtonSegment(value: false, label: Text('Privato')),
                ],
                selected: {_isPublic},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isPublic = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Profit toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Torneo a scopo di lucro',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _hasProfit,
                onChanged: (value) {
                  setState(() {
                    _hasProfit = value;
                    if (value) {
                      _prize1 = true;
                    }
                  });
                },
                activeColor: ATLColors.getPrimaryColor(widget.currentSport),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Start Date (Month)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedMonth,
              hint: const Text('Data inizio (mese)'),
              items: _getAvailableMonths().map((month) {
                return DropdownMenuItem(value: month, child: Text(month));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final validGroups = _getValidGroupCounts();
    final validQualified = _getValidQualifiedCounts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dettagli del torneo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Number of teams
        _buildSliderField(
          label: 'Numero di squadre',
          value: _numTeams.toDouble(),
          min: 6,
          max: 20,
          divisions: 16,
          onChanged: (value) {
            final newValue = value.toInt();
            // Check if it's not a prime number
            bool isPrime = true;
            if (newValue <= 1) {
              isPrime = false;
            } else if (newValue == 2) {
              isPrime = true;
            } else {
              for (int i = 2; i <= newValue ~/ 2; i++) {
                if (newValue % i == 0) {
                  isPrime = false;
                  break;
                }
              }
            }

            if (!isPrime) {
              setState(() {
                _numTeams = newValue;

                // Calculate new valid groups for the new numTeams
                List<int> newValidGroups = [];
                for (int g = 2; g <= newValue; g++) {
                  if (newValue % g == 0 && (newValue / g) >= 3) {
                    newValidGroups.add(g);
                  }
                }

                // Reset numGroups only if it's no longer valid
                if (_numGroups != null &&
                    !newValidGroups.contains(_numGroups)) {
                  _numGroups = null;
                }

                // Recalculate valid qualified counts if numGroups is still set
                if (_numGroups != null) {
                  List<int> newValidQualified = [];
                  int minQualified = 1;
                  while (minQualified < _numGroups!) {
                    minQualified *= 2;
                  }
                  int current = minQualified;
                  while (current < newValue) {
                    newValidQualified.add(current);
                    current *= 2;
                  }

                  // Reset qualified only if it's no longer valid
                  if (_qualified != null &&
                      !newValidQualified.contains(_qualified)) {
                    _qualified = null;
                  }
                } else {
                  // If numGroups was reset, also reset qualified
                  _qualified = null;
                }
              });
            }
          },
          formatValue: (v) => v.toInt().toString(),
        ),

        const SizedBox(height: 16),

        // Number of groups
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _numGroups,
              hint: const Text('Numero di gironi'),
              items: validGroups.map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text('$count gironi'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _numGroups = value;
                  // Reset qualified if it's no longer valid
                  if (_qualified != null &&
                      !validQualified.contains(_qualified)) {
                    _qualified = null;
                  }
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Round 2 option
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Round2Option>(
              isExpanded: true,
              value: _round2Option,
              hint: const Text('Andata e ritorno'),
              items: Round2Option.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _round2Option = value;
                  });
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Qualified teams
        if (_numGroups != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _qualified,
                hint: const Text('Squadre qualificate'),
                items: validQualified.map((count) {
                  return DropdownMenuItem(
                    value: count,
                    child: Text('$count squadre qualificate'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _qualified = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        if (_availableFields.isEmpty) ...[
          Center(
            child: Text(
              'Nessun campo disponibile per i criteri selezionati',
              style: TextStyle(fontSize: 16, color: ATLColors.subtext),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          ..._availableFields.map((field) {
            final isSelected = _selectedField?.id == field.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedField = field;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ATLColors.getPrimaryColor(
                            widget.currentSport,
                          ).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? ATLColors.getPrimaryColor(widget.currentSport)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              field.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? ATLColors.getPrimaryColor(
                                        widget.currentSport,
                                      )
                                    : ATLColors.darkBlue,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: ATLColors.getPrimaryColor(
                                widget.currentSport,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        field.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: ATLColors.subtext,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Inserisci descrizione',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Tournament name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome del torneo',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Tournament description
        TextField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Descrizione',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Inserisci le regole e i dettagli del torneo...',
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continua',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> _buildStep5() async {
    final fictitiousTournament = _createFictitiousTournament();

    // Calculate all values from backend
    final fee = await DB.Tournaments.calculateTournamentFee(
      fictitiousTournament,
    );
    final coordinatorPay = await DB.Tournaments.calculatePayCoordinator(
      fictitiousTournament,
    );

    // Calculate prizes only if requested
    final prize1Value = _prize1
        ? await DB.Tournaments.calculatePrize1(fictitiousTournament)
        : 0.0;
    final prize2Value = _prize2
        ? await DB.Tournaments.calculatePrize2(fictitiousTournament)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Riepilogo torneo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRowWidget(label: 'Nome', value: _nameController.text),
              InfoRowWidget(
                label: '1° posto',
                value: _prize1
                    ? '🏆 €${prize1Value.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: '2° posto',
                value: _prize2
                    ? '💰 €${prize2Value.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: 'Quota per squadra',
                value: '💵 €${fee.toStringAsFixed(2)}',
              ),
              InfoRowWidget(
                label: 'Campo',
                value: '${_selectedField!.name}, ${_selectedCity!}',
              ),
              InfoRowWidget(
                label: 'Numero di giocatori',
                value: _selectedSport!.maxPlayersPerTeam.toString(),
              ),
              InfoRowWidget(
                label: 'Inizio',
                value: _selectedMonth ?? 'Appena possibile',
              ),
              InfoRowWidget(
                label: 'Squadre',
                value: '$_numTeams  Gironi: $_numGroups  Qual: $_qualified',
              ),
              InfoRowWidget(
                label: 'Partite totali',
                value: _calculateTotalMatches().toString(),
              ),
              InfoRowWidget(
                label: 'Andata e ritorno',
                value: _round2Option.displayName,
              ),
              InfoRowWidget(
                label: 'Descrizione',
                value: _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : 'Nessuna descrizione fornita',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Coordinator pay
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ATLColors.getPrimaryColor(
              widget.currentSport,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ATLColors.getPrimaryColor(widget.currentSport),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Revenue totale',
                style: TextStyle(fontSize: 16, color: ATLColors.subtext),
              ),
              const SizedBox(height: 8),
              Text(
                '💵 €${coordinatorPay.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.getPrimaryColor(widget.currentSport),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _createTournament,
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CREA +',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  int _calculateTotalMatches() {
    if (_numGroups == null || _qualified == null) return 0;

    // Group stage matches
    final teamsPerGroup = _numTeams ~/ _numGroups!;
    final groupMatches =
        _numGroups! * (teamsPerGroup * (teamsPerGroup - 1)) ~/ 2;
    final groupMatchesTotal =
        _round2Option == Round2Option.groupStageOnly ||
            _round2Option == Round2Option.both
        ? groupMatches * 2
        : groupMatches;

    // Knockout stage matches
    int knockoutMatches =
        _qualified! - 1; // Each knockout round eliminates one team
    final knockoutMatchesTotal =
        _round2Option == Round2Option.finalStageOnly ||
            _round2Option == Round2Option.both
        ? knockoutMatches * 2
        : knockoutMatches;

    return groupMatchesTotal + knockoutMatchesTotal;
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String Function(double) formatValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatValue(value),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.getPrimaryColor(widget.currentSport),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: ATLColors.getPrimaryColor(widget.currentSport),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
