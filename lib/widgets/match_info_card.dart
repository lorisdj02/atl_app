import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/football_match.dart';
import '../models/sport_category.dart';
import '../models/referee_assignment.dart';
import '../models/referee.dart';
import '../models/field.dart';
import '../models/city.dart';
import '../utils/atl_colors.dart';
import '../database/db_controller.dart';
import 'info_row_with_icon.dart';

class MatchInfoCard extends StatefulWidget {
  final FootballMatch match;
  final bool isNotScheduled;
  final bool isScheduled;
  final SportCategory sportCategory;

  const MatchInfoCard({
    super.key,
    required this.match,
    required this.isNotScheduled,
    required this.isScheduled,
    required this.sportCategory,
  });

  @override
  State<MatchInfoCard> createState() => _MatchInfoCardState();
}

class _MatchInfoCardState extends State<MatchInfoCard> {
  bool _isExpanded = true;
  List<String>? _refereeRoles;
  List<RefereeAssignment>? _refereeAssignments;
  Map<String, String>? _refereesMap; // key: Name+Surname, value: Role
  bool _isLoadingReferees = true;
  int? _sportId;
  int? _fieldId;
  Field? _field;
  City? _city;
  bool _isLoadingField = true;

  @override
  void initState() {
    super.initState();
    _loadRefereeRoles();
    _loadFieldInfo();
  }

  Future<void> _loadFieldInfo() async {
    try {
      final int fieldId =
          await DB.Tournaments.getFieldId(widget.match.tournamentId) ?? 0;

      if (fieldId == 0) {
        setState(() {
          _isLoadingField = false;
        });
        return;
      }

      final field = await DB.Fields.getById(fieldId);

      final city = await DB.Cities.getById(field.cityId);

      if (mounted) {
        setState(() {
          _fieldId = fieldId;
          _field = field;
          _city = city;
          _isLoadingField = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingField = false;
        });
      }
    }
  }

  Future<void> _loadRefereeRoles() async {
    try {
      final int sportId =
          await DB.Tournaments.getSportId(widget.match.tournamentId) ?? 0;
      final int fieldId =
          await DB.Tournaments.getFieldId(widget.match.tournamentId) ?? 0;

      if (sportId == 0 || fieldId == 0) {
        setState(() {
          _refereeRoles = [];
          _refereeAssignments = [];
          _refereesMap = {};
          _isLoadingReferees = false;
        });
        return;
      }
      List<String> roles = [];
      if (sportId == 1 || sportId == 2 || sportId == 3) {
        // Football 5, Football 7, Football 8
        roles = ['MAIN'];
      } else if (sportId == 4) {
        // Football 11
        roles = ['MAIN', 'ASSISTANT1', 'ASSISTANT2'];
      } else {
        // Other sports can be added here with their respective roles
        roles = [];
      }
      final assignments = await DB.RefereeAssignments.getByMatchId(
        widget.match.id,
      );

      // Build referees map
      final Map<String, String> refereesMap = {};
      for (var assignment in assignments) {
        final referee = await DB.Referees.getByRefereeId(assignment.refereeId);
        if (referee != null) {
          final refereeName = '${referee.name} ${referee.surname}';
          refereesMap[assignment.role] = refereeName;
        }
      }

      if (mounted) {
        setState(() {
          _refereeRoles = roles;
          _refereeAssignments = assignments;
          _refereesMap = refereesMap;
          _isLoadingReferees = false;
          _sportId = sportId;
          _fieldId = fieldId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _refereeRoles = [];
          _refereeAssignments = [];
          _refereesMap = {};
          _isLoadingReferees = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Permetti di collassare solo se il match non è notScheduled o scheduled
    final bool canCollapse = !widget.isNotScheduled && !widget.isScheduled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: canCollapse
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ATLColors.getPrimaryColor(widget.sportCategory),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Match Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ATLColors.darkBlue,
                    ),
                  ),
                ),
                if (canCollapse)
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: ATLColors.darkBlue,
                  ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            if (widget.match.scheduledStart == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Match not scheduled yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRowWithIcon(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat(
                      'EEEE, MMMM d, y',
                    ).format(widget.match.scheduledStart!),
                    color: ATLColors.getPrimaryColor(widget.sportCategory),
                  ),
                  const Divider(height: 24),
                  InfoRowWithIcon(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: DateFormat(
                      'HH:mm',
                    ).format(widget.match.scheduledStart!),
                    color: Colors.green,
                  ),
                  const Divider(height: 24),
                  _isLoadingField
                      ? const InfoRowWithIcon(
                          icon: Icons.location_on,
                          label: 'Field',
                          value: 'Loading...',
                          color: Colors.orange,
                        )
                      : InfoRowWithIcon(
                          icon: Icons.location_on,
                          label: 'Field',
                          value: _field != null
                              ? '${_field!.name}${_city != null ? ' - ${_city!.name}' : ''}'
                              : 'Field #$_fieldId',
                          color: Colors.orange,
                        ),
                  const Divider(height: 24),
                  _isLoadingReferees
                      ? const InfoRowWithIcon(
                          icon: Icons.sports,
                          label: 'Referees',
                          value: 'Loading...',
                          color: Colors.blue,
                        )
                      : (_refereesMap == null || _refereesMap!.isEmpty)
                      ? const InfoRowWithIcon(
                          icon: Icons.sports,
                          label: 'Referees',
                          value: 'No referees assigned',
                          color: Colors.blue,
                        )
                      : InfoRowWithIcon(
                          icon: Icons.sports,
                          label: 'Referees',
                          multipleValues: _refereesMap,
                          color: Colors.blue,
                        ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
