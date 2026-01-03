import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../models/football_match.dart';

/// Widget che mostra il minutaggio in tempo reale della partita
class FootballLiveMinuteWidget extends StatefulWidget {
  final FootballMatch match;
  final int minutesPerRound;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;
  final SportCategory sportCategory;
  final int minutesPerPause;

  const FootballLiveMinuteWidget({
    super.key,
    required this.match,
    required this.fontSize,
    required this.padding,
    required this.borderRadius,
    required this.minutesPerRound,
    required this.sportCategory,
    required this.minutesPerPause,
  });

  @override
  State<FootballLiveMinuteWidget> createState() => _FootballLiveMinuteWidgetState();
}

class _FootballLiveMinuteWidgetState extends State<FootballLiveMinuteWidget> {
  late Timer _timer;
  int _currentMinute = 0;
  int _additionalMinutes = 0;
  int _remainingSeconds = 0; // Per halftime countdown

  @override
  void initState() {
    super.initState();
    _calculateCurrentMinute();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Aggiorna il minutaggio ogni secondo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateCurrentMinute();
      }
    });
  }

  void _calculateCurrentMinute() {
    final now = DateTime.now();
    int minute = 0;
    int additional = 0;
    int remainingSeconds = 0;

    switch (widget.match.status) {
      case MatchStatus.started:
        // Primo tempo
        if (widget.match.startMatch != null) {
          final diff = now.difference(widget.match.startMatch!);
          final totalMinutes = diff.inMinutes;
          if (totalMinutes > widget.minutesPerRound) {
            minute = widget.minutesPerRound;
            additional = totalMinutes - widget.minutesPerRound;
          } else {
            minute = totalMinutes;
          }
        }
        break;

      case MatchStatus.halftime:
        // Riposo - countdown da minutesPerPause a 0 con secondi
        if (widget.match.halfTime != null) {
          final diff = now.difference(widget.match.halfTime!);
          final totalSeconds = widget.minutesPerPause * 60 - diff.inSeconds;

          if (totalSeconds <= 0) {
            // Tempo scaduto, resta a 0:00
            minute = 0;
            remainingSeconds = 0;
          } else {
            // Countdown attivo
            minute = totalSeconds ~/ 60;
            remainingSeconds = totalSeconds % 60;
          }
        } else {
          minute = widget.minutesPerPause;
          remainingSeconds = 0;
        }
        break;

      case MatchStatus.startHalf:
        // Secondo tempo
        if (widget.match.startHalf != null) {
          final diff = now.difference(widget.match.startHalf!);
          final totalMinutes = widget.minutesPerRound + diff.inMinutes;
          if (totalMinutes > widget.minutesPerRound * 2) {
            minute = widget.minutesPerRound * 2;
            additional = totalMinutes - (widget.minutesPerRound * 2);
          } else {
            minute = totalMinutes;
          }
        } else {
          minute = widget.minutesPerRound;
        }
        break;

      case MatchStatus.finished:
        // Partita finita - mostra 90'
        minute = widget.minutesPerRound * 2;
        break;

      default:
        minute = 0;
    }

    if (mounted &&
        (_currentMinute != minute ||
            _additionalMinutes != additional ||
            _remainingSeconds != remainingSeconds)) {
      setState(() {
        _currentMinute = minute;
        _additionalMinutes = additional;
        _remainingSeconds = remainingSeconds;
      });
    }
  }

  Color _getContainerColor() {
    // In corso con minuti aggiuntivi -> rosso
    if ((widget.match.status == MatchStatus.started ||
            widget.match.status == MatchStatus.startHalf) &&
        _additionalMinutes > 0) {
      return Colors.red.shade700;
    }

    // Halftime a 0:00 -> rosso
    if (widget.match.status == MatchStatus.halftime &&
        _currentMinute == 0 &&
        _remainingSeconds == 0) {
      return Colors.red.shade700;
    }

    // In corso senza minuti aggiuntivi -> colore primario dello sport
    if (widget.match.status == MatchStatus.started ||
        widget.match.status == MatchStatus.startHalf) {
      return ATLColors.getPrimaryColor(widget.sportCategory);
    }

    // Halftime countdown attivo -> arancione
    if (widget.match.status == MatchStatus.halftime) {
      return Colors.orange.shade700;
    }

    // Altri casi (finished, ecc.) -> grigio
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    String displayText;

    if (widget.match.status == MatchStatus.halftime) {
      // Durante halftime mostra mm:ss
      String seconds = _remainingSeconds.toString().padLeft(2, '0');
      displayText = "$_currentMinute:$seconds";
    } else if (_additionalMinutes > 0) {
      // Minuti aggiuntivi
      displayText = "$_currentMinute'+$_additionalMinutes";
    } else {
      // Normale
      displayText = "$_currentMinute'";
    }

    return Container(
      margin: EdgeInsets.only(top: widget.fontSize * 0.167),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _getContainerColor(),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
