import 'package:atl_app/config/api_json_keys.dart';

class RegisterAccountRequest {
  final String email;
  final String username;
  final String fireBaseUid;
  final String name;
  final String surname;
  final String role;
  final String phone;
  final DateTime birthdate;
  final String? inviteCode;
  final String? profilePictureUrl;

  RegisterAccountRequest({
    required this.email,
    required this.username,
    required this.fireBaseUid,
    required this.name,
    required this.surname,
    required this.role,
    required this.phone,
    required this.birthdate,
    this.inviteCode,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      ApiJsonKeys.email: email,
      ApiJsonKeys.username: username,
      ApiJsonKeys.fireBaseUid: fireBaseUid,
      ApiJsonKeys.name: name,
      ApiJsonKeys.surname: surname,
      ApiJsonKeys.role: role,
      ApiJsonKeys.phone: phone,
      ApiJsonKeys.birthdate: birthdate.toIso8601String(),
      ApiJsonKeys.inviteCode: inviteCode,
      ApiJsonKeys.profilePictureUrl: profilePictureUrl,
    };
  }
}