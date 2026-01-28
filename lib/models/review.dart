enum ReviewType {
  referee,
  coordinator;

  String get displayName {
    switch (this) {
      case ReviewType.referee:
        return 'Referee';
      case ReviewType.coordinator:
        return 'Coordinator';
    }
  }
}

class Review {
  final int id;
  final int? matchId;
  final int? tournamentId;
  final int reviewerUserId;
  final int reviewedUserId;
  final ReviewType reviewType;
  final String comment;
  final int rating;

  Review({
    required this.id,
    this.matchId,
    this.tournamentId,
    required this.reviewType,
    required this.comment,
    required this.rating,
    required this.reviewerUserId,
    required this.reviewedUserId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      matchId: json['match_id'],
      tournamentId: json['tournament_id'],
      reviewType: ReviewType.values.firstWhere(
          (e) => e.displayName == json['review_type']),
      comment: json['comment'],
      rating: json['rating'],
      reviewerUserId: json['reviewer_user_id'],
      reviewedUserId: json['reviewed_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'tournament_id': tournamentId,
      'review_type': reviewType.displayName,
      'comment': comment,
      'rating': rating,
      'reviewer_user_id': reviewerUserId,
      'reviewed_user_id': reviewedUserId,
    };
  }
}
