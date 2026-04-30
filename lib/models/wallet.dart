// OK
class Wallet {
  final double id;
  final double prizeBalance;
  final double personalBalance;
  final double inviteBalance;
  final DateTime? prizeLastWithdraw;
  final DateTime? personalLastWithdraw;

  Wallet({
    required this.id,
    required this.prizeBalance,
    required this.personalBalance,
    required this.inviteBalance,
    required this.prizeLastWithdraw,
    required this.personalLastWithdraw,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      prizeBalance: json['prizeBalance'],
      personalBalance: json['personalBalance'],
      inviteBalance: json['inviteBalance'],
      prizeLastWithdraw: json['prizeLastWithdraw'] != null
          ? DateTime.parse(json['prizeLastWithdraw'])
          : null,
      personalLastWithdraw: json['personalLastWithdraw'] != null
          ? DateTime.parse(json['personalLastWithdraw'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prizeBalance': prizeBalance,
      'personalBalance': personalBalance,
      'inviteBalance': inviteBalance,
      'prizeLastWithdraw': prizeLastWithdraw?.toIso8601String(),
      'personalLastWithdraw': personalLastWithdraw?.toIso8601String(),
    };
  }
}
