import 'package:flutter/material.dart';
import '../../database/db_controller.dart';
import '../../models/tournament.dart';
import '../../models/tournament_participation.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/participation_card.dart';

class PayParticipationScreen extends StatefulWidget {
  final int teamId;
  final SportCategory sportCategory;
  final int playerId;

  const PayParticipationScreen({
    super.key,
    required this.teamId,
    required this.sportCategory,
    required this.playerId,
  });

  @override
  State<PayParticipationScreen> createState() => _PayParticipationScreenState();
}

class _PayParticipationScreenState extends State<PayParticipationScreen> {
  List<TournamentParticipation>? _participations;
  final Map<int, Tournament?> _tournamentCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipations();
  }

  Future<void> _loadParticipations() async {
    try {
      final participations = await DB.TournamentParticipations.getByTeamId(
        widget.teamId,
      );
      final pendingPayments = participations
          .where((p) => (p.toPay ?? 0) > 0)
          .toList();

      for (var participation in pendingPayments) {
        final tournament = await DB.Tournaments.getById(
          participation.tournamentId,
        );
        _tournamentCache[participation.tournamentId] = tournament;
      }

      if (mounted) {
        setState(() {
          _participations = pendingPayments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading participations: $e')),
        );
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pending Payments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingATL()
          : _participations == null || _participations!.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'No pending payments',
                    style: TextStyle(fontSize: 18, color: ATLColors.subtext),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _participations!.length,
              itemBuilder: (context, index) {
                final participation = _participations![index];
                final tournament = _tournamentCache[participation.tournamentId];
                return ParticipationCard(
                  participation: participation,
                  tournament: tournament,
                  playerId: widget.playerId,
                  sportCategory: widget.sportCategory,
                  onPaymentCompleted: _loadParticipations,
                );
              },
            ),
    );
  }
}
