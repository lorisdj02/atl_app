import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/atl_role_selector.dart';
import '../organization_contact_screen.dart';

class RegistrationScreenStep1 extends StatelessWidget {
  final UserRole? selectedRole;
  final Function(UserRole) onRoleSelected;

  const RegistrationScreenStep1({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ATLRoleSelector(
          role: UserRole.coordinator,
          isSelected: selectedRole == UserRole.coordinator,
          onTap: () => onRoleSelected(UserRole.coordinator),
        ),
        ATLRoleSelector(
          role: UserRole.player,
          isSelected: selectedRole == UserRole.player,
          onTap: () => onRoleSelected(UserRole.player),
        ),
        ATLRoleSelector(
          role: UserRole.referee,
          isSelected: selectedRole == UserRole.referee,
          onTap: () => onRoleSelected(UserRole.referee),
        ),
        ATLRoleSelector(
          role: UserRole.organization,
          isSelected: selectedRole == UserRole.organization,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OrganizationContactScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
