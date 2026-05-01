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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      prizeBalance: json['prizeBalance'] != null ? (json['prizeBalance'] as num).toDouble() : 0.0,
      personalBalance: json['personalBalance'] != null ? (json['personalBalance'] as num).toDouble() : 0.0,
      inviteBalance: json['inviteBalance'] != null ? (json['inviteBalance'] as num).toDouble() : 0.0,
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
