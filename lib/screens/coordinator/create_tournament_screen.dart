import 'package:atl_app/database/services/field_service.dart';
import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/database/responses/tournament_parameters_response.dart';
import 'package:atl_app/database/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/sport.dart';
import '../../models/field.dart';
import '../../models/city.dart';
import '../../models/enums/sport_category.dart';
import '../../models/tournament.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/atl_step_indicator.dart';
import '../../widgets/sport_selector_widget.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/field_size_alert_dialog.dart';
import '../../widgets/tournament_summary.dart';
import '../../models/enums/tournament_status.dart';
import '../../models/enums/tournament_phase.dart';

enum Round2Option { none, groupStageOnly, finalStageOnly, both }

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
  double? _selectedCityId; // cityId
  bool _isPublic = true;
  bool _hasProfit = true;
  String? _selectedMonth; // 'asap' or 'YYYY-MM'

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
  List<Field> _fields = [];
  List<City> _cities = [];
  Map<double, int> _maxPlayerPerField = {};

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    final l10n = AppLocalizations.of(context);

    // Validation for each step
    if (_currentStep == 0 && _selectedSport == null) {
      _showError(l10n.selectSportFirst);
      return;
    }

    if (_currentStep == 1 && !_canProceedFromStep1()) {
      _showError(l10n.fillAllFields);
      return;
    }

    if (_currentStep == 2 && !_canProceedFromStep2()) {
      _showError(l10n.completeTournamentDetails);
      return;
    }

    if (_currentStep == 3 && _selectedField == null) {
      _showError(l10n.selectFieldFirst2);
      return;
    }

    if (_currentStep == 4 && !_canProceedFromStep4()) {
      _showError(l10n.insertNameAndDescription);
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
    return _selectedCityId != null && _selectedMonth != null;
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

  Future<void> _loadCities() async {
    try {
      final cities = await FieldService.Read.getAllCities();
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      if (mounted) {
        _showError(
          AppLocalizations.of(context).errorLoadingCities(e.toString()),
        );
      }
    }
  }

  Future<void> _loadAvailableFields() async {
    if (_selectedCityId == null || _selectedSport == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final FieldsAndMaxPlayersPerFieldResponse data =
          await FieldService.Read.getFieldsByMaxPlayersAndCityAndSportCategory(
            maxPlayers: _selectedSport!.maxPlayersPerTeam,
            cityId: _selectedCityId!.toDouble(),
            sportCategory: _selectedSport!.sportCategory,
          );

      setState(() {
        _fields = data.fields;
        _maxPlayerPerField = data.maxPlayersPerField;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorLoadingFieldsShort(e.toString()),
            ),
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

    // Valori fissi: 2, 4, 8, 16
    List<int> fixedValues = [2, 4, 8, 16];

    // Filtra solo i valori che sono:
    // 1. >= numGroups
    // 2. < numTeams
    return fixedValues
        .where((value) => value >= _numGroups! && value < _numTeams)
        .toList();
  }

  Tournament _createFictitiousTournament() {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);

    if (userProvider.activeAccount == null ||
        userProvider.activeRoleId == null ||
        userProvider.isCoordinator == false) {
      throw Exception(AppLocalizations.of(context).coordinatorNotFound);
    }

    // Parse start date
    DateTime? startDate;
    if (_selectedMonth != null && _selectedMonth != 'asap') {
      final parts = _selectedMonth!.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      startDate = DateTime(year, month, 1);
    }

    return Tournament(
      id: 0,
      name: _nameController.text.trim(),
      coordinatorId: userProvider.activeRoleId!,
      fieldId: _selectedField!.id,
      cityId: _selectedCityId!,
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
      numTeamsQualified: _qualified!,
      description: _descriptionController.text.trim(),
      fee: 0,
      prize1: 0,
      prize2: 0,
      isPublic: _isPublic,
      isFavorite: false,
      isParticipating: false,
      status: TournamentStatus.created,
      atlEvent: false,
      photoUrl: null,
      phase: TournamentPhase.group,
    );
  }

  List<String> _getAvailableMonths() {
    List<String> months = ['asap'];
    final now = DateTime.now();

    // Add current month and next 2 months
    for (int i = 0; i < 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }

    return months;
  }

  Future<void> _createTournament() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<AccountProvider>(context, listen: false);
      final currentUser = userProvider.activeAccount;

      if (currentUser == null ||
          userProvider.activeRoleId == null ||
          userProvider.isCoordinator == false) {
        throw Exception(AppLocalizations.of(context).coordinatorNotFound);
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
      if (_selectedMonth != null && _selectedMonth != 'asap') {
        final parts = _selectedMonth!.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        startDate = DateTime(year, month, 1);
      }

      Tournament dummyTournament = _createFictitiousTournament();

      final Tournament createdTournament =
          await TournamentService.Write.createTournament(dummyTournament);

      if (mounted && createdTournament.id != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tournamentCreatedSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorCreatingTournament(e.toString()),
            ),
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

  double _getSportId() {
    return _selectedSport!.id;
  }

  String _getSportDisplayName([int? maxPlayers]) {
    final sportName = _selectedSport!.sportCategory.name.toUpperCase();
    final playersPerSide = maxPlayers != null
        ? maxPlayers ~/ 2
        : _selectedSport!.minPlayersPerTeam;
    return '$sportName ${playersPerSide}v$playersPerSide';
  }

  bool _isFieldOversized(Field field) {
    if (_selectedSport == null || _maxPlayerPerField[field.id] == null)
      return false;
    final minPlayers = _selectedSport!.minPlayersPerTeam * 2;
    return minPlayers < _maxPlayerPerField[field.id]!;
  }

  String _formatMonthOption(AppLocalizations l10n, String value) {
    if (value == 'asap') return l10n.asSoonAsPossible;

    final parts = value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('MMMM yyyy', locale).format(DateTime(year, month, 1));
  }

  String _round2OptionLabel(AppLocalizations l10n, Round2Option option) {
    switch (option) {
      case Round2Option.none:
        return l10n.roundFormatSingleMatch;
      case Round2Option.groupStageOnly:
        return l10n.roundFormatHomeAwayGroups;
      case Round2Option.finalStageOnly:
        return l10n.roundFormatHomeAwayFinals;
      case Round2Option.both:
        return l10n.roundFormatFullHomeAway;
    }
  }

  Future<void> _showOversizedFieldWarning(Field field) async {
    return showDialog(
      context: context,
      builder: (context) => FieldSizeAlertDialog(
        field: field,
        customMessage: AppLocalizations.of(
          context,
        ).oversizedFieldDialogMessage(_maxPlayerPerField[field.id]!),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        title: Text(
          l10n.createTournamentTitle,
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
              final l10n = AppLocalizations.of(context);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.errorLoadingData(snapshot.error.toString()),
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
    final l10n = AppLocalizations.of(context);
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
          title: l10n.selectSportStep,
          subtitle: l10n.chooseSportCategory,
        ),
        const SizedBox(height: 32),
        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          onPressed: _goToNextStep,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.logisticsDetailsTitle,
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
              Text(
                l10n.firstPlacePrize,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
              Text(
                l10n.secondPlacePrize,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
            child: DropdownButton<double>(
              isExpanded: true,
              value: _selectedCityId,
              hint: Text(l10n.cityHint),
              items: _cities.map((city) {
                return DropdownMenuItem(value: city.id, child: Text(city.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCityId = value;
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
              Text(
                l10n.visibilityLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.publicTournament),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.privateTournament),
                  ),
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
              Text(
                l10n.forProfitTournament,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
              hint: Text(l10n.startMonthHint),
              items: _getAvailableMonths().map((monthValue) {
                return DropdownMenuItem(
                  value: monthValue,
                  child: Text(_formatMonthOption(l10n, monthValue)),
                );
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

        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          onPressed: _goToNextStep,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final l10n = AppLocalizations.of(context);
    final validGroups = _getValidGroupCounts();
    final validQualified = _getValidQualifiedCounts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tournamentDetails,
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
          label: l10n.numberOfTeamsLabel,
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
                  // Valori fissi: 2, 4, 8, 16
                  List<int> fixedValues = [2, 4, 8, 16];
                  List<int> newValidQualified = fixedValues
                      .where(
                        (value) => value >= _numGroups! && value < newValue,
                      )
                      .toList();

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
              hint: Text(l10n.numberOfGroupsHint),
              items: validGroups.map((count) {
                return DropdownMenuItem(
                  value: count,
                  child: Text(l10n.groupsCount(count)),
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
              hint: Text(l10n.homeAndAwayHint),
              items: Round2Option.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(_round2OptionLabel(l10n, option)),
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
                hint: Text(l10n.qualifiedTeamsHint),
                items: validQualified.map((count) {
                  return DropdownMenuItem(
                    value: count,
                    child: Text(l10n.qualifiedTeamsCount(count)),
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

        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          onPressed: _goToNextStep,
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
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        if (_fields.isEmpty) ...[
          Center(
            child: Text(
              l10n.noFieldsAvailableForCriteria,
              style: TextStyle(fontSize: 16, color: ATLColors.subtext),
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

          ..._fields.map((field) {
            final isSelected = _selectedField?.id == field.id;
            final isOversized = _isFieldOversized(field);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
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
                        l10n.fieldForSport(
                          _getSportDisplayName(_maxPlayerPerField[field.id]!),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        field.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: ATLColors.subtext,
                        ),
                      ),
                      if (isOversized) ...[
                        const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],

        const SizedBox(height: 32),

        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          onPressed: _goToNextStep,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep4() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.insertDescriptionTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Tournament name
        ATLTextField(
          controller: _nameController,
          hintText: l10n.tournamentNameHint,
        ),

        const SizedBox(height: 16),

        // Tournament description
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.tournamentDescHint,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 16,
              ),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          onPressed: _goToNextStep,
          fullWidth: true,
        ),
      ],
    );
  }

  Future<Widget> _buildStep5() async {
    final l10n = AppLocalizations.of(context);
    final fictitiousTournament = _createFictitiousTournament();
    try {
      final TournamentParametersResponse data = await TournamentService
          .Read.calculateTournamentParameters(fictitiousTournament);

      // Calculate all values from backend
      final fee = data.fee;
      final coordinatorPay = data.coordinatorPay;
      final prize1Value = data.prize1;
      final prize2Value = data.prize2;

      // Get city name
      final City city = _cities.firstWhere((c) => c.id == _selectedCityId);
      final cityName = city.name;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.tournamentSummaryTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ATLColors.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          TournamentSummary(
            tournament: fictitiousTournament,
            sport: _selectedSport!,
            field: _selectedField!,
            cityName: cityName,
            fee: fee,
            prize1Value: prize1Value,
            prize2Value: prize2Value,
            totalMatches: _calculateTotalMatches(),
            round2Display: _round2OptionLabel(l10n, _round2Option),
            primaryColor: ATLColors.getPrimaryColor(widget.currentSport),
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
                  l10n.totalRevenueLabel,
                  style: TextStyle(fontSize: 16, color: ATLColors.subtext),
                ),
                const SizedBox(height: 8),
                Text(
                  '€${coordinatorPay.toStringAsFixed(2)}',
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

          ATLButton(
            text: l10n.createTournamentButton,
            size: ATLButtonSize.large,
            isFilled: true,
            color: ATLColors.getPrimaryColor(widget.currentSport),
            onPressed: _createTournament,
            fullWidth: true,
          ),
        ],
      );
    } catch (e) {
      throw Exception(l10n.errorGeneric(e.toString()));
    }
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
