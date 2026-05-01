import 'enums/sport_category.dart';
import 'enums/review_type.dart';

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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      tournamentId: json['tournamentId'] != null
          ? (json['tournamentId'] as num).toDouble()
          : 0.0,
      matchId: json['matchId'] != null
          ? (json['matchId'] as num).toDouble()
          : 0.0,
      reviewerAccountId: json['reviewerAccountId'] != null
          ? (json['reviewerAccountId'] as num).toDouble()
          : 0.0,
      reviewedAccountId: json['reviewedAccountId'] != null
          ? (json['reviewedAccountId'] as num).toDouble()
          : 0.0,
      comment: json['comment'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      type: ReviewTypeExtension.fromJson(json['type']),
      sportCategory: json['sportCategory'] != null
          ? SportCategoryExtension.fromJson(json['sportCategory'])
          : SportCategory.football,
    );
  }
}
