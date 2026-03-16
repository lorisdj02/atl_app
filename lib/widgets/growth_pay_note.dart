import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
class GrowthPayNote extends StatelessWidget {
  const GrowthPayNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ATLColors.lightBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: ATLColors.darkBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.growthPayNote,
              style: TextStyle(color: ATLColors.darkBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
