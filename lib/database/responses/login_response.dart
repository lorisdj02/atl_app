

import 'package:atl_app/models/account.dart';
import '../../config/api_json_keys.dart'; 

class LoginResponse {
  final Account? account;
  final int? roleId;
  final int? teamId;


  LoginResponse({
    required this.account,
    required this.roleId,
    required this.teamId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      account: Account.fromJson(json[ApiJsonKeys.account]),
      roleId: json[ApiJsonKeys.roleId],
      teamId: json[ApiJsonKeys.teamId],

    );
  }

}
