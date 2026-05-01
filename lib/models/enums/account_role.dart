enum AccountRole {
  player,
  coordinator,
  referee,
  organization,
  admin,
  guest;

  String get displayName {
    switch (this) {
      case AccountRole.player:
        return 'Player';
      case AccountRole.coordinator:
        return 'Coordinator';
      case AccountRole.referee:
        return 'Referee';
      case AccountRole.organization:
        return 'Organization';
      case AccountRole.admin:
        return 'Admin';
      case AccountRole.guest:
        return 'Guest';
    }
  }

  String get apiValue {
    switch (this) {
      case AccountRole.player:
        return 'PLAYER';
      case AccountRole.coordinator:
        return 'COORDINATOR';
      case AccountRole.referee:
        return 'REFEREE';
      case AccountRole.organization:
        return 'ORGANIZATION';
      case AccountRole.guest:
        return 'GUEST';
      case AccountRole.admin:
        return 'ADMIN';
    }
  }
}

extension AccountRoleExtension on AccountRole {
  static AccountRole fromJson(String json) {
    final normalized = json.toUpperCase();
    return AccountRole.values.firstWhere(
      (e) => e.apiValue == normalized,
      orElse: () => throw ArgumentError('Unknown account role: $json'),
    );
  }
}