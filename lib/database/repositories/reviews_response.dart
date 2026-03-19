import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/models/review.dart';

class ReviewsResponse {
  final List<Review> reviews;
  final Map<int, Account> accountPerReview;
  final Map<int, String> matchTeamsStringPerReview;

  ReviewsResponse({
    required this.reviews,
    required this.accountPerReview,
    required this.matchTeamsStringPerReview,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews: List<Review>.from(
        json[ApiJsonKeys.reviews].map((x) => Review.fromJson(x)),
      ),
      accountPerReview: Map<int, Account>.from(
        json[ApiJsonKeys.accountPerReview].map(
          (key, value) => MapEntry(int.parse(key), Account.fromJson(value)),
        ),
      ),
      matchTeamsStringPerReview: Map<int, String>.from(
        json[ApiJsonKeys.matchTeamsStringPerReview].map(
          (key, value) => MapEntry(int.parse(key), value),
        ),
      ),
    );
  }
}
