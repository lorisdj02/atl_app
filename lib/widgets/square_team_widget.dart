import 'package:flutter/material.dart';
import 'abstract_team_widget.dart';
import '../utils/atl_colors.dart';

/// Widget quadrato per visualizzare un team in formato compatto
class SquareTeamWidget extends AbstractTeamWidget {
  final bool isClickable;

  const SquareTeamWidget({
    super.key,
    required super.team,
    required super.sportCategory,
    super.imageUrl,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isClickable ? () => handleTeamTap(context) : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ATLColors.getPrimaryColor(sportCategory).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: (imageUrl ?? team.imageUrl) != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl ?? team.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield,
            color: ATLColors.getPrimaryColor(sportCategory),
            size: 32,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              team.alias,
              style: TextStyle(
                color: ATLColors.getPrimaryColor(sportCategory),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
