
import 'package:atl_app/config/api_json_keys.dart';

class UpdateAccountInfoRequest {
  final String? username;
  final String? phone;
  final DateTime? birthdate;
  final String? imageUrl;
  final int? preferredCityId;

  UpdateAccountInfoRequest({
    required this.username,
    required this.phone,
    required this.birthdate,
    required this.imageUrl,
    required this.preferredCityId,
  });

  Map<String, dynamic> toJson() {
    return {
      ApiJsonKeys.username: username,
      ApiJsonKeys.phone: phone,
      ApiJsonKeys.birthdate: birthdate?.toIso8601String(),
      ApiJsonKeys.imageUrl: imageUrl,
      ApiJsonKeys.preferredCityId: preferredCityId,
    };
  }
}
