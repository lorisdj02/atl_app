import 'package:atl_app/config/api_json_keys.dart';

class InviteFriendsResponse {
  final double inviteBalance;
  final String referralCode;
  final int numRedeemed;
  final int numInvites;

  InviteFriendsResponse({
    required this.inviteBalance,
    required this.referralCode,
    required this.numRedeemed,
    required this.numInvites,
  });

  factory InviteFriendsResponse.fromJson(Map<String, dynamic> json) {
    final double inviteBalance = (json[ApiJsonKeys.inviteBalance] as num)
        .toDouble();
    print("Invite balance parsed: $inviteBalance");

    final String referralCode = json[ApiJsonKeys.referralCode] as String;
    print("Referral code parsed: $referralCode");

    final int numRedeemed = (json[ApiJsonKeys.numRedeemed] as num).toInt();
    print("Number of redeemed invites parsed: $numRedeemed");

    final int numInvites = (json[ApiJsonKeys.numInvites] as num).toInt();
    print("Number of invites parsed: $numInvites");

    return InviteFriendsResponse(
      inviteBalance: inviteBalance,
      referralCode: referralCode,
      numRedeemed: numRedeemed,
      numInvites: numInvites,
    );
  }
}
