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
      invitedId: json['invitedId'],
      inviterId: json['inviterId'],
      redeemed: json['redeemed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitedId': invitedId,
      'inviterId': inviterId,
      'redeemed': redeemed,
    };
  }
}