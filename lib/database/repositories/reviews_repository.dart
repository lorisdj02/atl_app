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

  List<Review> _mockData = [];

  @override
  List<Review> get mockData => _mockData;

  Future<List<Review>> getByReviewedUserId(int revieweeUserId) async {
    if (AppConfig.isDebug) {
      return mockData
          .where((review) => review.revieweeUserId == revieweeUserId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Review>> getByReviewerUserId(int reviewerUserId) async {
    if (AppConfig.isDebug) {
      final List<Review> reviews = mockData
          .where((review) => review.reviewerUserId == reviewerUserId)
          .toList();

      for (var review in reviews) {
        print(
            'Review ${review.id} - reviewerUserId: ${review.reviewerUserId}, revieweeUserId: ${review.revieweeUserId}, status: ${review.status}');
      }
      return reviews;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addReview({
    required int reviewerUserId,
    required int revieweeUserId,
    required int tournamentId,
    required ReviewType reviewType,
    String? comment,
    required double weight,
    int? matchId,
  }) async {
    if (AppConfig.isDebug) {
      final newReview = Review(
        id:
            _mockData
                .map((e) => e.id)
                .fold(0, (prev, element) => element > prev ? element : prev) +
            1,
        reviewerUserId: reviewerUserId,
        revieweeUserId: revieweeUserId,
        reviewType: reviewType,
        tournamentId: tournamentId,
        matchId: matchId,
        weight: weight,
        createdAt: DateTime.now(),
      );

      _mockData.add(newReview);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> commitReview(
    int reviewId, {
    required double rating,
    String? comment,
  }) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere((review) => review.id == reviewId);
      if (index != -1) {
        _mockData[index].status = ReviewStatus.committed;
        _mockData[index].committedAt = DateTime.now();
        _mockData[index].rating = rating;
        _mockData[index].comment = comment;
        return true;
      }
      return false;
    } else {
      throw UnimplementedError();
    }
  }

  Future<Review?> getById(int reviewId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.firstWhere((review) => review.id == reviewId),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Review>> getPendingReviewsForReviewerUserId(int userId) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (review) =>
                review.reviewerUserId == userId &&
                review.status == ReviewStatus.pending,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }
}
