import 'package:atl_app/database/responses/pay_participation_response.dart';
import 'package:atl_app/database/services/team_service.dart';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/tournament_participation.dart';
import '../../models/enums/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/participation_card.dart';
import '../../l10n/app_localizations.dart';

class PayParticipationScreen extends StatefulWidget {
  final double teamId;
  final SportCategory sportCategory;
  final double playerId;

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
  List<TournamentParticipation> _tournamentParticipations = [];
  Map<double, Tournament?> _tournamentsCache = {};
  Map<double, bool> _isCalledUpPerTournament = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final PayParticipationResponse data = await TeamService
          .Read.getPayParticipationScreen(widget.teamId.toDouble());

      setState(() {
        _tournamentParticipations = data.tournamentParticipations;
        _tournamentsCache = data.tournamentsCache;
        _isCalledUpPerTournament = data.isCalledUpPerTournament;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingData(e.toString()),
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
        _tournamentParticipations = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.pendingPaymentsTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingATL()
          : _tournamentParticipations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    l10n.noPendingPayments,
                    style: const TextStyle(
                      fontSize: 18,
                      color: ATLColors.subtext,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tournamentParticipations.length,
              itemBuilder: (context, index) {
                final participation = _tournamentParticipations[index];
                final tournament =
                    _tournamentsCache[participation.tournamentId];
                return ParticipationCard(
                  participation: participation,
                  tournament: tournament,
                  playerId: widget.playerId,
                  sportCategory: widget.sportCategory,
                  onPaymentCompleted: _loadData,
                  isCalledUp:
                      _isCalledUpPerTournament[participation.tournamentId] ??
                      false,
                );
              },
            ),
    );
  }
}
