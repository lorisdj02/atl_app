import 'package:atl_app/config/api_json_keys.dart';

class HasNotificationsResponse {
  bool hasUnreadNotifications;
  bool isVip;

  HasNotificationsResponse({
    required this.hasUnreadNotifications,
    required this.isVip,
  });

  factory HasNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return HasNotificationsResponse(
      hasUnreadNotifications: json[ApiJsonKeys.hasUnreadNotifications] as bool,
      isVip: json[ApiJsonKeys.isVip] as bool,
    );
  }
}
