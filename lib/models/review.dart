import 'sport_category.dart';

enum ReviewType {
  refereeToCoordinator,
  coordinatorToReferee,
  playerToCoordinator;

  String get apiName {
    switch (this) {
      case ReviewType.refereeToCoordinator:
        return 'REFEREE_TO_COORDINATOR';
      case ReviewType.coordinatorToReferee:
        return 'COORDINATOR_TO_REFEREE';
      case ReviewType.playerToCoordinator:
        return 'PLAYER_TO_COORDINATOR';
    }
  }
}

enum ReviewStatus {
  waiting,
  pending,
  committed;

  String get apiName {
    switch (this) {
      case ReviewStatus.waiting:
        return 'WAITING';
      case ReviewStatus.pending:
        return 'PENDING';
      case ReviewStatus.committed:
        return 'COMMITTED';
    }
  }
}

// OK
class Review {
  final double id;
  final double tournamentId;
  final double? matchId;
  final double reviewerAccountId;
  final double reviewedAccountId;
  final String? comment;
  final double rating;
  final ReviewType type;
  final SportCategory sportCategory;

  Review({
    required this.id,
    required this.tournamentId,
    required this.matchId,
    required this.reviewerAccountId,
    required this.reviewedAccountId,
    required this.comment,
    required this.rating,
    required this.type,
    required this.sportCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'matchId': matchId,
      'reviewerAccountId': reviewerAccountId,
      'reviewedAccountId': reviewedAccountId,
      'comment': comment,
      'rating': rating,
      'type': type.apiName,
      'sportCategory': sportCategory.apiName,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      tournamentId: json['tournamentId'],
      matchId: json['matchId'],
      reviewerAccountId: json['reviewerAccountId'],
      reviewedAccountId: json['reviewedAccountId'],
      comment: json['comment'],
      rating: json['rating'],
      type: ReviewType.values.firstWhere((e) => e.apiName == json['type']),
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
      ),
    );
  }
}
