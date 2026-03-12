import 'package:atl_app/utils/atl_colors.dart';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/player.dart';
import '../../models/sport_category.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';

class ViewCallupsScreen extends StatefulWidget {
  final Tournament tournament;
  final int teamId;
  final SportCategory sportCategory;

  const ViewCallupsScreen({
    Key? key,
    required this.tournament,
    required this.teamId,
    required this.sportCategory,
  }) : super(key: key);

  @override
  State<ViewCallupsScreen> createState() => _ViewCallupsScreenState();
}

class _ViewCallupsScreenState extends State<ViewCallupsScreen> {
  List<Player> _calledUpPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallUps();
  }

  Future<void> _loadCallUps() async {
    setState(() => _isLoading = true);

    try {
      final data = await DBRead.getViewCallupsScreen(
        widget.tournament.id,
        widget.teamId,
      );
      
      if (mounted) {
        setState(() {
          _calledUpPlayers = data[ApiJsonKeys.players];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading call-ups: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Call-ups',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _calledUpPlayers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No call-ups found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _calledUpPlayers.length,
              itemBuilder: (context, index) {
                final player = _calledUpPlayers[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      player.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
