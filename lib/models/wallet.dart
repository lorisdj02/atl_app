class Wallet {
  final int id;
  final int userId;
  int balance;
  int prizeBalance;
  DateTime? lastWithdraw;
  DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    this.balance = 0,
    this.prizeBalance = 0,
  }) : lastWithdraw = null,
       updatedAt = DateTime.now();

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      balance: json['balance'] ?? 0,
      prizeBalance: json['prizeBalance'] ?? 0,
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
      'balance': balance,
      'prizeBalance': prizeBalance,
      'lastWithdraw': lastWithdraw?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
