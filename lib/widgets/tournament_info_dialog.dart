import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import 'tournament_summary.dart';

class TournamentInfoDialog extends StatefulWidget {
  final Tournament tournament;
  final SportCategory sportCategory;

  const TournamentInfoDialog({
    super.key,
    required this.tournament,
    required this.sportCategory,
  });

  @override
  State<TournamentInfoDialog> createState() => _TournamentInfoDialogState();
}

class _TournamentInfoDialogState extends State<TournamentInfoDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 8),
            // Tournament Summary with scrollbar
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    ATLColors.getPrimaryColor(widget.sportCategory),
                  ),
                  trackColor: WidgetStateProperty.all(
                    ATLColors.getPrimaryColor(widget.sportCategory)
                        .withOpacity(0.2),
                  ),
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                  thickness: WidgetStateProperty.all(8),
                  radius: const Radius.circular(4),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 8),
                    child: TournamentSummary(
                      tournament: widget.tournament,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
