import 'package:atl_app/database/responses/tournament_summary_response.dart';
import 'package:atl_app/database/services/tournament_service.dart';
import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/sport.dart';
import '../models/field.dart';
import '../widgets/info_row_widget.dart';
import '../l10n/app_localizations.dart';

/// Widget for displaying tournament summary information
class TournamentSummary extends StatelessWidget {
  final Tournament tournament;
  final Sport? sport;
  final Field? field;
  final String? cityName;
  final double? fee;
  final double? prize1Value;
  final double? prize2Value;
  final int? totalMatches;
  final String? round2Display;
  final Color? primaryColor;

  const TournamentSummary({
    super.key,
    required this.tournament,
    this.sport,
    this.field,
    this.cityName,
    this.fee,
    this.prize1Value,
    this.prize2Value,
    this.totalMatches,
    this.round2Display,
    this.primaryColor,
  });

  String _getSportDisplayName(Sport? sportData) {
    if (sportData == null) return 'N/A';
    final sportName = sportData.category.name.toUpperCase();
    final playersPerSide = sportData.minPlayersPerTeam;
    return '$sportName ${playersPerSide}v$playersPerSide';
  }

  String _getStartDateDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (tournament.startDate == null) {
      return l10n.asSoonAsPossible;
    }
    final date = tournament.startDate!;
    return '${_getMonthName(context, date.month)} ${date.year}';
  }

  String _getMonthName(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context);
    List<String> months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return months[month - 1];
  }

  String _getRound2Display(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (tournament.round2GroupStage && tournament.round2FinalStage) {
      return l10n.formatFullHomeAndAway;
    } else if (tournament.round2GroupStage) {
      return l10n.formatHomeAndAwayGroupStage;
    } else if (tournament.round2FinalStage) {
      return l10n.formatHomeAndAwayKnockoutStage;
    }
    return l10n.formatSingleMatchOnly;
  }

  int _calculateTotalMatches() {
    final teamsPerGroup = tournament.numTeams ~/ tournament.numGroups;
    final groupMatches =
        tournament.numGroups * (teamsPerGroup * (teamsPerGroup - 1)) ~/ 2;
    final groupMatchesTotal = tournament.round2GroupStage
        ? groupMatches * 2
        : groupMatches;

    int knockoutMatches = tournament.qualified - 1;
    final knockoutMatchesTotal = tournament.round2FinalStage
        ? knockoutMatches * 2
        : knockoutMatches;

    return groupMatchesTotal + knockoutMatchesTotal;
  }

  Future<Map<String, dynamic>> _fetchData(BuildContext context) async {
    final TournamentSummaryResponse data = await TournamentService.Read.getTournamentSummary(tournament.id.toDouble());


    final sportData = sport ?? data.sport;
    final fieldData = field ?? data.field;
    final cityNameData = cityName ?? data.cityName;

    final feeData = fee ?? tournament.fee;
    final prize1Data = prize1Value ?? tournament.prize1;
    final prize2Data = prize2Value ?? tournament.prize2;
    final totalMatchesData = totalMatches ?? _calculateTotalMatches();
    final round2DisplayData = round2Display ?? _getRound2Display(context);

    return {
      'sport': sportData,
      'field': fieldData,
      'cityName': cityNameData,
      'fee': feeData,
      'prize1': prize1Data > 0 ? prize1Data : null,
      'prize2': prize2Data > 0 ? prize2Data : null,
      'totalMatches': totalMatchesData,
      'round2Display': round2DisplayData,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(l10n.errorLoadingData(snapshot.error.toString())),
          );
        }

        final data = snapshot.data!;
        final sportData = data['sport'] as Sport?;
        final fieldData = data['field'] as Field?;
        final cityNameData = data['cityName'] as String;
        final feeData = data['fee'] as double;
        final prize1Data = data['prize1'] as double?;
        final prize2Data = data['prize2'] as double?;
        final totalMatchesData = data['totalMatches'] as int;
        final round2DisplayData = data['round2Display'] as String;

        return Container(
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
              InfoRowWidget(label: l10n.name, value: tournament.name),
              InfoRowWidget(
                label: l10n.firstPlaceLabel,
                value: prize1Data != null
                    ? '🏆 €${prize1Data.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: l10n.secondPlaceLabel,
                value: prize2Data != null
                    ? '💰 €${prize2Data.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: l10n.feeLabel,
                value: '💵 €${feeData.toStringAsFixed(2)}',
              ),
              InfoRowWidget(
                label: l10n.fieldLabel,
                value: '${fieldData?.name ?? 'N/A'}, $cityNameData',
              ),
              InfoRowWidget(
                label: l10n.sportLabel,
                value: _getSportDisplayName(sportData),
              ),
              InfoRowWidget(label: l10n.selectDateRequired, value: _getStartDateDisplay(context)),
              InfoRowWidget(label: l10n.teamsLabel, value: '${tournament.numTeams}'),
              InfoRowWidget(label: l10n.groupsLabel, value: '${tournament.numGroups}'),
              InfoRowWidget(
                label: l10n.qualifiedTeamsLabel,
                value: '${tournament.qualified}',
              ),
              InfoRowWidget(
                label: l10n.totalMatchesLabel,
                value: totalMatchesData.toString(),
              ),
              InfoRowWidget(
                label: l10n.round2Label,
                value: round2DisplayData,
              ),
              InfoRowWidget(
                label: l10n.descriptionLabel,
                value: tournament.description.isNotEmpty
                    ? tournament.description
                    : l10n.noDescriptionProvided,
              ),
            ],
          ),
        );
      },
    );
  }
}
