import 'base_repository.dart';
import '../../models/review.dart';
import '../../config/app_config.dart';

class ReviewsRepository extends BaseRepository<Review> {
  @override
  String get endpoint => 'reviews';

  @override
  Review fromJson(Map<String, dynamic> json) {
    return Review.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Review item) {
    return item.toJson();
  }

  List<Review> _mockdata = [];

  @override
  List<Review> get mockData => _mockdata;

  Future<List<Review>> getByReviewedUserId(int reviewedUserId) async {
    if (AppConfig.isDebug) {
      return mockData
          .where((review) => review.reviewedUserId == reviewedUserId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Review>> getByReviewerUserId(int reviewerUserId) async {
    if (AppConfig.isDebug) {
      return mockData
          .where((review) => review.reviewerUserId == reviewerUserId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addReview(
    int reviewerUserId,
    int reviewedUserId,
    ReviewType reviewType,
    String comment,
    int rating,
  ) async {
    if (AppConfig.isDebug) {
      final newReview = Review(
        id:
            _mockdata
                .map((e) => e.id)
                .fold(0, (prev, element) => element > prev ? element : prev) +
            1,
        reviewerUserId: reviewerUserId,
        reviewedUserId: reviewedUserId,
        reviewType: reviewType,
        comment: comment,
        rating: rating,
      );
      _mockdata.add(newReview);
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }
}
