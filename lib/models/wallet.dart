class Wallet {
  final int id;
  final int userId;
  double personalBalance;
  double prizeBalance;
  double inviteBalance;
  DateTime? lastWithdraw;
  DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    this.personalBalance = 0,
    this.prizeBalance = 0,
    this.inviteBalance = 0,
  }) : lastWithdraw = null,
       updatedAt = DateTime.now();

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      personalBalance: json['personalBalance'] ?? 0,
      prizeBalance: json['prizeBalance'] ?? 0,
      inviteBalance: json['inviteBalance'] ?? 0,
    )
      ..lastWithdraw = json['lastWithdraw'] != null
          ? DateTime.parse(json['lastWithdraw'])
          : null
      ..updatedAt = DateTime.parse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'personalBalance': personalBalance,
      'prizeBalance': prizeBalance,
      'lastWithdraw': lastWithdraw?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'inviteBalance': inviteBalance,
    };
  }
}
