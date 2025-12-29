import 'dart:async';
import 'package:flutter/material.dart';
import '../models/soccer_match.dart';

/// Widget che mostra il minutaggio in tempo reale della partita
class LiveMinuteWidget extends StatefulWidget {
  final SoccerMatch match;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;

  const LiveMinuteWidget({
    super.key,
    required this.match,
    required this.fontSize,
    required this.padding,
    required this.borderRadius,
  });

  @override
  State<LiveMinuteWidget> createState() => _LiveMinuteWidgetState();
}

class _LiveMinuteWidgetState extends State<LiveMinuteWidget> {
  late Timer _timer;
  int _currentMinute = 0;

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

    switch (widget.match.status) {
      case MatchStatus.started:
        // Primo tempo
        if (widget.match.startMatch != null) {
          final diff = now.difference(widget.match.startMatch!);
          minute = diff.inMinutes;
          // Cap a 45 minuti per il primo tempo
          if (minute > 45) minute = 45;
        }
        break;

      case MatchStatus.halftime:
        // Riposo - mostra 45'
        minute = 45;
        break;

      case MatchStatus.startHalf:
        // Secondo tempo
        if (widget.match.startHalf != null) {
          final diff = now.difference(widget.match.startHalf!);
          minute = 45 + diff.inMinutes;
          // Cap a 90 minuti
          if (minute > 90) minute = 90;
        } else {
          minute = 45;
        }
        break;

      case MatchStatus.finished:
        // Partita finita - mostra 90'
        minute = 90;
        break;

      default:
        minute = 0;
    }

    if (mounted && _currentMinute != minute) {
      setState(() {
        _currentMinute = minute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.fontSize * 0.167),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Text(
        "$_currentMinute'",
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
