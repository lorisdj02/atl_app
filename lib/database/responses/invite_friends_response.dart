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
    return InviteFriendsResponse(
      inviteBalance: (json[ApiJsonKeys.inviteBalance] as num).toDouble(),
      referralCode: json[ApiJsonKeys.referralCode] as String,
      numRedeemed: (json[ApiJsonKeys.numRedeemed] as num).toInt(),
      numInvites: (json[ApiJsonKeys.numInvites] as num).toInt(),
    );
  }
}
