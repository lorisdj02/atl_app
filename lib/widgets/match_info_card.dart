import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/football_match.dart';
import '../models/sport_category.dart';
import '../models/field.dart';
import '../utils/atl_colors.dart';
import 'info_row_with_icon.dart';

class MatchInfoCard extends StatefulWidget {
  final FootballMatch match;
  final bool isNotScheduled;
  final bool isScheduled;
  final SportCategory sportCategory;
  final Field field;
  final String cityName;
  final Map<String, String> assignmentPerRefereeNameSurname;

  const MatchInfoCard({
    super.key,
    required this.match,
    required this.isNotScheduled,
    required this.isScheduled,
    required this.sportCategory,
    required this.field,
    required this.cityName,
    required this.assignmentPerRefereeNameSurname,
  });

  @override
  State<MatchInfoCard> createState() => _MatchInfoCardState();
}

class _MatchInfoCardState extends State<MatchInfoCard> {
  bool _isExpanded = true;
  // Data is passed via props, no async loading needed
  final bool _isLoadingReferees = false;
  final bool _isLoadingField = false;

  @override
  void initState() {
    super.initState();
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
                          value: "${widget.field.name} - ${widget.cityName}",
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
                      : (widget.assignmentPerRefereeNameSurname.isEmpty)
                      ? const InfoRowWithIcon(
                          icon: Icons.sports,
                          label: 'Referees',
                          value: 'No referees assigned',
                          color: Colors.blue,
                        )
                      : InfoRowWithIcon(
                          icon: Icons.sports,
                          label: 'Referees',
                          multipleValues: widget.assignmentPerRefereeNameSurname,
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
