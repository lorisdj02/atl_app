import 'package:flutter/material.dart';
import '../../widgets/atl_role_selector.dart';
import '../organization_contact_screen.dart';
import '../../models/enums/account_role.dart';

class RegistrationScreenStep1 extends StatelessWidget {
  final AccountRole? selectedRole;
  final Function(AccountRole) onRoleSelected;

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
          role: AccountRole.player,
          isSelected: selectedRole == AccountRole.player,
          onTap: () => onRoleSelected(AccountRole.player),
        ),
        ATLRoleSelector(
          role: AccountRole.coordinator,
          isSelected: selectedRole == AccountRole.coordinator,
          onTap: () => onRoleSelected(AccountRole.coordinator),
        ),
        ATLRoleSelector(
          role: AccountRole.referee,
          isSelected: selectedRole == AccountRole.referee,
          onTap: () => onRoleSelected(AccountRole.referee),
        ),
        ATLRoleSelector(
          role: AccountRole.organization,
          isSelected: selectedRole == AccountRole.organization,
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
