class FriendInvite{
  final int inviterAccountId;
  final int invitedAccountId;
  bool redeemed;

  FriendInvite({
    required this.invitedAccountId,
    required this.inviterAccountId,
    this.redeemed = false,
  });

  factory FriendInvite.fromJson(Map<String, dynamic> json) {
    return FriendInvite(
      invitedAccountId: json['invitedAccountId'],
      inviterAccountId: json['inviterAccountId'],
      redeemed: json['redeemed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitedAccountId': invitedAccountId,
      'inviterAccountId': inviterAccountId,
      'redeemed': redeemed,
    };
  }
}