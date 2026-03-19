import 'sport_category.dart';

enum ReviewType {
  refereeToCoordinator,
  coordinatorToReferee,
  playerToCoordinator,
}

enum ReviewStatus { waiting, pending, committed }

class Review {
  final int id;
  final int tournamentId;
  final int? matchId; // opzionale, se la recensione è legata a una partita specifica
  final ReviewType reviewType;
  String? comment;
  double? rating; // da 1 a 5
  final int reviewerAccountId; // id dell'utente
  final int reviewedAccountId; // id dell'utente recensito
  final DateTime createdAt;
  DateTime? committedAt; // data di commit della recensione, se è stata committata
  double weight; // peso della recensione, da 0 a 1
  ReviewStatus status;
  final SportCategory sportCategory; // categoria sportiva a cui si riferisce la recensione

  Review({
    required this.id,
    required this.tournamentId,
    required this.matchId,
    required this.reviewType,
    this.comment,
    this.rating,
    required this.reviewerAccountId,
    required this.createdAt,
    this.committedAt, // default a now
    required this.reviewedAccountId,
    this.weight = 0.5, // default a 0.5
    this.status = ReviewStatus.waiting, // default a waiting
    this.sportCategory = SportCategory.football, // default a generic
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      tournamentId: json['tournamentId'],
      reviewType: ReviewType.values[json['reviewType']],
      comment: json['comment'],
      rating: json['rating'],
      reviewerAccountId: json['reviewerAccountId'],
      reviewedAccountId: json['reviewedAccountId'],
      matchId: json['matchId'], // può essere null
      createdAt: DateTime.parse(json['createdAt']),
      weight: json['weight'] ?? 0.5,
      status: ReviewStatus.values[json['status'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'reviewType': reviewType.index,
      'comment': comment,
      'rating': rating,
      'reviewerAccountId': reviewerAccountId,
      'reviewedAccountId': reviewedAccountId,
      'createdAt': createdAt.toIso8601String(),
      'weight': weight,
      'status': status.index,
      'matchId': matchId, // può essere null
    };
  }
}
