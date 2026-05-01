import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/models/review.dart';

class ReviewsResponse {
  final List<Review> reviews;
  final Map<double, Account> accountPerReview;
  final Map<double, String> matchTeamsStringPerReview;

  ReviewsResponse({
    required this.reviews,
    required this.accountPerReview,
    required this.matchTeamsStringPerReview,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews: (json[ApiJsonKeys.reviews] as List)
          .map((e) => Review.fromJson(e))
          .toList(),
      accountPerReview: (json[ApiJsonKeys.accountPerReview] as Map<String, dynamic>).map(
        (key, value) => MapEntry(double.parse(key), Account.fromJson(value)),
      ),
      matchTeamsStringPerReview: (json[ApiJsonKeys.matchTeamsStringPerReview] as Map<String, dynamic>).map(
        (key, value) => MapEntry(double.parse(key), value as String),
      ),
    );
  }
}