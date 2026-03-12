import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../utils/atl_colors.dart';
import '../database/db_write.dart';
import '../models/sport_category.dart';

class ReviewWidget extends StatefulWidget {
  final Review review;
  final User? reviewee;
  final String? matchTeamsString;
  final VoidCallback onCommitted;

  const ReviewWidget({
    super.key,
    required this.review,
    required this.reviewee,
    this.matchTeamsString,
    required this.onCommitted,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final List<double> _ratings = [0.0, 0.0, 0.0];

  bool get _allRated => _ratings.every((r) => r >= 0.5);
  final TextEditingController _commentController = TextEditingController();
  bool _isCommitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _commit() async {
    if (!_allRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate all fields (minimum 0.5 stars each).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final avgRating = (_ratings[0] + _ratings[1] + _ratings[2]) / 3.0;
    final comment = _commentController.text.trim();

    setState(() => _isCommitting = true);

    final success = await DBWrite.commitReview(
      widget.review.id,
      rating: avgRating,
      comment: comment.isEmpty ? null : comment,
      tournamentId: widget.review.tournamentId,
      matchId: widget.review.matchId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onCommitted();
    } else {
      setState(() => _isCommitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit review.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final sportColor = ATLColors.getPrimaryColor(review.sportCategory);
    final fields = _getFields(review.reviewType);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewee card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviewing',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        widget.reviewee?.username ?? '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.matchTeamsString != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.matchTeamsString!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _reviewTypeLabel(review.reviewType),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sportColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(review.sportCategory.icon, color: Colors.white, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            review.sportCategory.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sub-field ratings card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  fields.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: i < fields.length - 1 ? 20 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fields[i],
                          style: const TextStyle(
                            color: ATLColors.darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StarRatingRow(
                          value: _ratings[i],
                          onChanged: (v) => setState(() => _ratings[i] = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Comment
          const Text(
            'Comment (optional)',
            style: TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Commit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCommitting ? null : _commit,
              icon: _isCommitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isCommitting ? 'Submitting...' : 'Commit Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ATLColors.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<String> _getFields(ReviewType type) {
    switch (type) {
      case ReviewType.coordinatorToReferee:
        return ['Impartiality', 'Competence', 'Match management'];
      case ReviewType.refereeToCoordinator:
      case ReviewType.playerToCoordinator:
        return ['Organisation', 'Communication', 'Availability'];
    }
  }

  static String _reviewTypeLabel(ReviewType type) {
    switch (type) {
      case ReviewType.coordinatorToReferee:
        return 'Coordinator → Referee';
      case ReviewType.refereeToCoordinator:
        return 'Referee → Coordinator';
      case ReviewType.playerToCoordinator:
        return 'Player → Coordinator';
    }
  }
}

class StarRatingRow extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const StarRatingRow({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, _buildStarSlot),
    );
  }

  Widget _buildStarSlot(int i) {
    final full = value >= i + 1;
    final half = !full && value >= i + 0.5;
    const double size = 48.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            child: Icon(
              full
                  ? Icons.star
                  : half
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: 40,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: size / 2,
            child: GestureDetector(
              onTap: () => onChanged(i + 0.5),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size / 2,
            child: GestureDetector(
              onTap: () => onChanged(i + 1.0),
              behavior: HitTestBehavior.opaque,
            ),
          ),
        ],
      ),
    );
  }
}
