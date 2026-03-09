class FriendInvite{
  final int inviterId;
  final int invitedId;
  bool redeemed;

  FriendInvite({
    required this.invitedId,
    required this.inviterId,
    this.redeemed = false,
  });

  factory FriendInvite.fromJson(Map<String, dynamic> json) {
    return FriendInvite(
      invitedId: json['invited_id'],
      inviterId: json['inviter_id'],
      redeemed: json['redeemed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invited_id': invitedId,
      'inviter_id': inviterId,
      'redeemed': redeemed,
    };
  }
}