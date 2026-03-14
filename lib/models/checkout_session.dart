enum CheckoutSessionStatus {
  pending,
  completed,
  expired,
  failed,
}

enum CheckoutType {
  tournamentFee,
  lobbyBookingCreate,
  lobbyBookingParticipate,
  privateBooking
}

class CheckoutSession {
  final int id;
  final int userId;
  final String payload;
  final double amount;
  final DateTime createdAt;
  CheckoutSessionStatus status;
  final CheckoutType type;
  final DateTime expiresAt;

  CheckoutSession({
    required this.id,
    required this.userId,
    required this.payload,
    required this.amount,
    required this.createdAt,
    required this.status,
    required this.type,
    required this.expiresAt,
  });

  static CheckoutSessionStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return CheckoutSessionStatus.pending;
      case 'completed':
        return CheckoutSessionStatus.completed;
      case 'expired':
        return CheckoutSessionStatus.expired;
      case 'failed':
        return CheckoutSessionStatus.failed;
      default:
        throw ArgumentError('Unknown status: $status');
    }
  }

  static CheckoutType _parseType(String type) {
    switch (type) {
      case 'tournamentFee':
        return CheckoutType.tournamentFee;
      case 'lobbyBookingCreate':
        return CheckoutType.lobbyBookingCreate;
      case 'lobbyBookingParticipate':
        return CheckoutType.lobbyBookingParticipate;
      case 'privateBooking':
        return CheckoutType.privateBooking;
      default:
        throw ArgumentError('Unknown type: $type');
    }
  }

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'],
      userId: json['userId'],
      payload: json['payload'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: _parseStatus(json['status']),
      type: _parseType(json['type']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'payload': payload,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}