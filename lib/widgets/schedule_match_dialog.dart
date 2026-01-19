import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../database/db_controller.dart';

class ScheduleMatchDialog extends StatefulWidget {
  final int tournamentId;
  final int fieldId;
  final SportCategory currentSport;
  final DateTime? currentScheduledStart;

  const ScheduleMatchDialog({
    super.key,
    required this.tournamentId,
    required this.fieldId,
    required this.currentSport,
    this.currentScheduledStart,
  });

  @override
  State<ScheduleMatchDialog> createState() => _ScheduleMatchDialogState();
}

class _ScheduleMatchDialogState extends State<ScheduleMatchDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = true;
  int _minutesPerRound = 0;
  int _minutesPerPause = 0;
  int _totalBookingDuration = 0;
  List<TimeOfDay> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() => _isLoading = true);

    try {
      final sportId = await DB.Tournaments.getById(
        widget.tournamentId,
      ).then((t) => t!.sportId);
      final sport = await DB.Sports.getById(sportId);

      if (sport != null) {
        _minutesPerRound = sport.minutesPerRound;
        _minutesPerPause = sport.minutesPerPause;
        // minutesPerRound*2 + minutesPerPause + 30 (15 before + 15 after)
        _totalBookingDuration = (_minutesPerRound * 2) + _minutesPerPause + 30;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading tournament data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() => _isLoading = true);

    try {
      final List<TimeOfDay> slots = [];
      final now = DateTime.now();

      // Load existing bookings for this field
      final existingBookings = await DB.Bookings.getByFieldId(widget.fieldId);

      // Generate time slots from 00:00 to 23:45 in 15-minute intervals
      for (int hour = 0; hour < 24; hour++) {
        for (int minute = 0; minute < 60; minute += 15) {
          final slot = TimeOfDay(hour: hour, minute: minute);

          // Create DateTime for the kickoff time
          final kickoffTime = DateTime(
            date.year,
            date.month,
            date.day,
            slot.hour,
            slot.minute,
          );

          // Skip if the kickoff time is less than 1 hour from now
          if (kickoffTime.isBefore(now.add(const Duration(hours: 1)))) {
            continue;
          }

          // Check if this slot + duration fits before midnight
          final totalMinutes = (hour * 60) + minute + _totalBookingDuration;
          if (totalMinutes <= 24 * 60) {
            // Create DateTime for the start and finish times
            final startTime = kickoffTime.subtract(
              const Duration(minutes: 15),
            ); // 15 min buffer before

            final finishTime = startTime.add(
              Duration(minutes: _totalBookingDuration),
            );

            // Check if this time slot conflicts with existing bookings
            bool hasConflict = false;
            for (var booking in existingBookings) {
              // Check if there's any overlap between the proposed booking and existing booking
              // Overlap occurs if: startTime < booking.finishTime AND finishTime > booking.startTime
              if (startTime.isBefore(booking.finishTime) &&
                  finishTime.isAfter(booking.startTime)) {
                hasConflict = true;
                break;
              }
            }

            // Only add the slot if there's no conflict
            if (!hasConflict) {
              // Also check if field is available via the existing method
              final freeFields = await DB.Bookings.getFreeFieldIds(
                startTime,
                finishTime,
                [widget.fieldId],
              );

              if (freeFields != null && freeFields.contains(widget.fieldId)) {
                slots.add(slot);
              }
            }
          }
        }
      }

      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading available slots: $e');
      setState(() {
        _availableSlots = [];
        _isLoading = false;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getBookingInfo() {
    if (_selectedDate == null || _selectedTime == null) return '';

    final kickoffTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final arrivalTime = kickoffTime.subtract(const Duration(minutes: 15));
    final endTime = kickoffTime.add(
      Duration(minutes: (_minutesPerRound * 2) + _minutesPerPause + 15),
    );

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return 'Field booked from ${timeFormat.format(arrivalTime)} to ${timeFormat.format(endTime)} '
        'on ${dateFormat.format(_selectedDate!)} with kickoff scheduled at ${timeFormat.format(kickoffTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: ATLColors.getPrimaryColor(widget.currentSport),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.currentScheduledStart == null
                      ? 'Schedule Match'
                      : 'Reschedule Match',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Picker
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = null; // Reset time when date changes
                  });
                  await _loadAvailableSlots(date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Available Time Slots
            if (_selectedDate != null) ...[
              const Text(
                'Available Time Slots (Kickoff Time):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableSlots.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No available time slots for this date',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _availableSlots[index];
                        final isSelected = _selectedTime == slot;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: ATLColors.getPrimaryColor(
                            widget.currentSport,
                          ).withOpacity(0.1),
                          leading: Icon(
                            Icons.access_time,
                            color: isSelected
                                ? ATLColors.getPrimaryColor(widget.currentSport)
                                : Colors.grey,
                          ),
                          title: Text(
                            _formatTime(slot),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? ATLColors.getPrimaryColor(
                                      widget.currentSport,
                                    )
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTime = slot;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 16),

            // Booking Info
            if (_selectedDate != null && _selectedTime != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ATLColors.getPrimaryColor(
                    widget.currentSport,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ATLColors.getPrimaryColor(
                      widget.currentSport,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getBookingInfo(),
                  style: TextStyle(
                    fontSize: 14,
                    color: ATLColors.getPrimaryColor(widget.currentSport),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_selectedDate != null && _selectedTime != null)
                        ? () {
                            final scheduledStart = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );
                            Navigator.pop(context, scheduledStart);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ATLColors.getPrimaryColor(
                        widget.currentSport,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONFIRM'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
