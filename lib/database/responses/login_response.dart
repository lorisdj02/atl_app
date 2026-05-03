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
    final Account? account = json[ApiJsonKeys.account] != null
        ? Account.fromJson(json[ApiJsonKeys.account])
        : null;
    print("Account parsed: ${account != null}");

    final double? roleId = (json[ApiJsonKeys.roleId] as num?)?.toDouble();
    print("Role ID parsed: $roleId");

    final double? teamId = (json[ApiJsonKeys.teamId] as num?)?.toDouble();
    print("Team ID parsed: $teamId");

    return LoginResponse(
      account: account,
      roleId: roleId,
      teamId: teamId,
    );
  }
}
