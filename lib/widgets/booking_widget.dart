import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_controller.dart';
import '../models/field.dart';
import '../models/player.dart';
import '../utils/atl_colors.dart';
import '../models/sport_category.dart';

class BookingWidget extends StatefulWidget {
  final int fieldId;
  final DateTime startTime;
  final DateTime finishTime;
  final int? ownerId; // Se presente, è una lobby booking
  final SportCategory currentSport;

  const BookingWidget({
    super.key,
    required this.fieldId,
    required this.startTime,
    required this.finishTime,
    this.ownerId,
    required this.currentSport,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  Field? _field;
  Player? _owner;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final field = await DB.Fields.getById(widget.fieldId);
      Player? owner;
      
      if (widget.ownerId != null) {
        owner = await DB.Players.getByPlayerId(widget.ownerId!);
      }

      if (mounted) {
        setState(() {
          _field = field;
          _owner = owner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_field == null) {
      return const Center(child: Text('Field not found'));
    }

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');
    final isLobby = widget.ownerId != null;

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
                // Nome campo
                Row(
                  children: [
                    Icon(
                      Icons.stadium,
                      color: ATLColors.darkBlue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _field!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.title,
                            ),
                          ),
                          Text(
                            _field!.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: ATLColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Data e orario
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: ATLColors.darkBlue, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(widget.startTime),
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
                    Icon(Icons.access_time, color: ATLColors.darkBlue, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${timeFormat.format(widget.startTime)} - ${timeFormat.format(widget.finishTime)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ATLColors.title,
                      ),
                    ),
                  ],
                ),

                // Owner (solo per lobby)
                if (isLobby && _owner != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: ATLColors.darkBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Owner: ${_owner!.username}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ATLColors.title,
                        ),
                      ),
                    ],
                  ),
                ],

                // Pulsante chat (solo per lobby)
                if (isLobby) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementare chat
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat - Coming soon')),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'OPEN CHAT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
