
import 'package:atl_app/config/api_json_keys.dart';

class UpdateAccountInfoRequest {
  final String? username;
  final String? phone;
  final DateTime? birthdate;
  final String? imageUrl;
  final double? preferredCityId;
  final bool? preferredCityTouched;

  UpdateAccountInfoRequest({
    required this.username,
    required this.phone,
    required this.birthdate,
    required this.imageUrl,
    required this.preferredCityId,
    this.preferredCityTouched,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (username != null) map[ApiJsonKeys.username] = username;
    if (phone != null) map[ApiJsonKeys.phone] = phone;
    if (birthdate != null) {
      map[ApiJsonKeys.birthdate] = birthdate!.toIso8601String();
    }
    if (imageUrl != null) map[ApiJsonKeys.imageUrl] = imageUrl;

    if (preferredCityId != null) {
      map[ApiJsonKeys.preferredCityId] = preferredCityId;
    } else if (preferredCityTouched == true) {
      map[ApiJsonKeys.preferredCityId] = null;
    }

    return map;
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
