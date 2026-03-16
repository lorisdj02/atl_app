import 'package:flutter/material.dart';
import '../config/api_json_keys.dart';
import '../database/db_read.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

typedef SearchResultCallback = void Function(Team? team, Tournament? tournament);

class SearchDialogWidget extends StatefulWidget {
  final int? teamId;
  final int? tournamentId;
  final bool isTeam;
  final bool isTournament;
  final SearchResultCallback? onFound;

  const SearchDialogWidget({
    super.key,
    this.teamId,
    this.tournamentId,
    required this.isTeam,
    required this.isTournament,
    this.onFound,
  }) : assert(isTeam != isTournament, 'Must specify either team or tournament search');

  @override
  State<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Team? _foundTeam;
  Tournament? _foundTournament;

  @override
  void initState() {
    super.initState();
    if (widget.teamId != null) {
      _idController.text = widget.teamId.toString();
    } else if (widget.tournamentId != null) {
      _idController.text = widget.tournamentId.toString();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context);
    final idText = _idController.text.trim();
    if (idText.isEmpty) {
      setState(() {
        _errorMessage = l10n.pleaseEnterIdError;
        _foundTeam = null;
        _foundTournament = null;
      });
      return;
    }

    final id = int.tryParse(idText);
    if (id == null) {
      setState(() {
        _errorMessage = l10n.invalidIdFormatError;
        _foundTeam = null;
        _foundTournament = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundTeam = null;
      _foundTournament = null;
    });

    try {
      if (widget.isTeam) {
        final data = await DBRead.searchTeamOrTournament(id, isTeam: true, isTournament: false);
        _foundTeam = data[ApiJsonKeys.team] as Team?;
        if (_foundTeam == null) {
          _errorMessage = l10n.teamNotFoundError;
        } else {
          widget.onFound?.call(_foundTeam, null);
          //Navigator.of(context).pop();
          return;
        }
      } else if (widget.isTournament) {
        final data = await DBRead.searchTeamOrTournament(id, isTeam: false, isTournament: true);
        _foundTournament = data[ApiJsonKeys.tournament] as Tournament?;
        if (_foundTournament == null) {
          _errorMessage = l10n.tournamentNotFoundError;
        } else {
          widget.onFound?.call(null, _foundTournament);
          //Navigator.of(context).pop();
          return;
        }
      }
    } catch (e) {
      _errorMessage = l10n.errorSearching(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: ATLColors.background,
      title: Text(widget.isTeam? l10n.searchByTeamId : l10n.searchByTournamentId),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: l10n.idLabel,
                hintText: widget.isTeam? l10n.enterTeamIdHint : l10n.enterTournamentIdHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: _search,
          child: Text(l10n.searchButton),
        ),
      ],
    );
  }
}