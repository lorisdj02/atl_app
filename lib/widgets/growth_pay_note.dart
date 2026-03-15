import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

class GrowthPayNote extends StatelessWidget {
  const GrowthPayNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ATLColors.lightBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: ATLColors.darkBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pay may vary by role within the same sport category. '
              'Figures shown are the min–max range across all roles for that level.',
              style: TextStyle(color: ATLColors.darkBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
