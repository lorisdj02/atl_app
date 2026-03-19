class Wallet {
  final int id;
  final int accountId;
  double personalBalance;
  double prizeBalance;
  double inviteBalance;
  DateTime? lastWithdraw;
  DateTime updatedAt;

  Wallet({
    required this.id,
    required this.accountId,
    this.personalBalance = 0,
    this.prizeBalance = 0,
    this.inviteBalance = 0,
  }) : lastWithdraw = null,
       updatedAt = DateTime.now();

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      accountId: json['accountId'],
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
      'accountId': accountId,
      'personalBalance': personalBalance,
      'prizeBalance': prizeBalance,
      'lastWithdraw': lastWithdraw?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'inviteBalance': inviteBalance,
    };
  }
}
