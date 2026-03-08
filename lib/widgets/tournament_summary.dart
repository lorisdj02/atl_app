import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/sport.dart';
import '../models/field.dart';
import '../widgets/info_row_widget.dart';
import '../database/db_read.dart';
import '../config/api_json_keys.dart';

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

  String _getStartDateDisplay() {
    if (tournament.startDate == null) {
      return 'Appena possibile';
    }
    final date = tournament.startDate!;
    return '${_getMonthName(date.month)} ${date.year}';
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

  String _getRound2Display() {
    if (tournament.round2GroupStage && tournament.round2FinalStage) {
      return 'Per tutto il torneo';
    } else if (tournament.round2GroupStage) {
      return 'Solo ai gironi';
    } else if (tournament.round2FinalStage) {
      return 'Solo nella fase finale';
    }
    return 'No';
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

  Future<Map<String, dynamic>> _fetchData() async {
    final data = await DBRead.getTournamentSummary(tournament.id);


    final sportData = sport ?? data[ApiJsonKeys.sport] as Sport?;
    final fieldData = field ?? data[ApiJsonKeys.field] as Field?;
    final cityNameData = cityName ?? data[ApiJsonKeys.cityName] as String? ?? 'N/A';

    final feeData = fee ?? tournament.fee;
    final prize1Data = prize1Value ?? tournament.prize1;
    final prize2Data = prize2Value ?? tournament.prize2;
    final totalMatchesData = totalMatches ?? _calculateTotalMatches();
    final round2DisplayData = round2Display ?? _getRound2Display();

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
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
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
            child: Text('Errore: ${snapshot.error}'),
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
              InfoRowWidget(label: 'Nome', value: tournament.name),
              InfoRowWidget(
                label: '1° posto',
                value: prize1Data != null
                    ? '🏆 €${prize1Data.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: '2° posto',
                value: prize2Data != null
                    ? '💰 €${prize2Data.toStringAsFixed(2)}'
                    : '❌ No',
              ),
              InfoRowWidget(
                label: 'Quota per squadra',
                value: '💵 €${feeData.toStringAsFixed(2)}',
              ),
              InfoRowWidget(
                label: 'Campo',
                value: '${fieldData?.name ?? 'N/A'}, $cityNameData',
              ),
              InfoRowWidget(
                label: 'Sport',
                value: _getSportDisplayName(sportData),
              ),
              InfoRowWidget(label: 'Inizio', value: _getStartDateDisplay()),
              InfoRowWidget(label: 'Squadre', value: '${tournament.numTeams}'),
              InfoRowWidget(label: 'Gironi', value: '${tournament.numGroups}'),
              InfoRowWidget(
                label: 'Squadre qualificate alla fase finale',
                value: '${tournament.qualified}',
              ),
              InfoRowWidget(
                label: 'Partite totali',
                value: totalMatchesData.toString(),
              ),
              InfoRowWidget(
                label: 'Andata e ritorno',
                value: round2DisplayData,
              ),
              InfoRowWidget(
                label: 'Descrizione',
                value: tournament.description.isNotEmpty
                    ? tournament.description
                    : 'Nessuna descrizione fornita',
              ),
            ],
          ),
        );
      },
    );
  }
}
