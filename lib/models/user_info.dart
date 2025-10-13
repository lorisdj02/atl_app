/// Enum per i ruoli utente
enum UserRole {
  player,
  coordinator,
  referee,
  organization,
}

/// Modello per le informazioni base dell'utente
class UserInfo {
  final String username;
  final UserRole role;
  final String? email;
  final String? profileImagePath;

  const UserInfo({
    required this.username,
    required this.role,
    this.email,
    this.profileImagePath,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.player:
        return 'Player';
      case UserRole.coordinator:
        return 'Coordinator';
      case UserRole.referee:
        return 'Referee';
      case UserRole.organization:
        return 'Organization';
    }
  }
}
