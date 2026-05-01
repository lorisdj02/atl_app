import 'package:atl_app/models/account.dart';
import '../../config/api_json_keys.dart';

class LoginResponse {
  final Account? account;
  final double? roleId;
  final double? teamId;

  LoginResponse({
    required this.account,
    required this.roleId,
    required this.teamId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      account: Account.fromJson(json[ApiJsonKeys.account]),
      roleId: json[ApiJsonKeys.roleId] != null
          ? double.parse(json[ApiJsonKeys.roleId].toString())
          : null,
      teamId: json[ApiJsonKeys.teamId] != null
          ? double.parse(json[ApiJsonKeys.teamId].toString())
          : null,
    );
  }
}
