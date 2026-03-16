import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/atl_button.dart';
import '../../l10n/app_localizations.dart';

class RegistrationScreenStep3 extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController inviteCodeController;
  final String? profileImagePath;
  final Function(String?) onProfileImageChanged;
  final Future<void> Function() onRegister;
  final VoidCallback onBack;
  final bool isLoading;

  const RegistrationScreenStep3({
    super.key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.inviteCodeController,
    required this.profileImagePath,
    required this.onProfileImageChanged,
    required this.onRegister,
    required this.onBack,
    required this.isLoading,
  });

  @override
  State<RegistrationScreenStep3> createState() =>
      _RegistrationScreenStep3State();
}

class _RegistrationScreenStep3State extends State<RegistrationScreenStep3> {
  bool _obscurePassword = true;

  Future<void> _pickProfileImage() async {
    final l10n = AppLocalizations.of(context);
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImageSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) widget.onProfileImageChanged(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Profile image picker
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFB0B0B0),
                  shape: BoxShape.circle,
                  image: widget.profileImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(widget.profileImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.profileImagePath == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: ATLColors.darkBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Email *
        ATLTextField(
          controller: widget.emailController,
          hintText: l10n.emailRequired,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Username *
        ATLTextField(
          controller: widget.usernameController,
          hintText: l10n.usernameRequired,
        ),

        const SizedBox(height: 16),

        // Password *
        ATLTextField(
          controller: widget.passwordController,
          hintText: l10n.passwordRequired,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: ATLColors.darkBlue,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        const SizedBox(height: 16),

        // Invite code (optional)
        ATLTextField(
          controller: widget.inviteCodeController,
          hintText: l10n.inviteCodeOptional,
        ),

        const SizedBox(height: 30),

        // Register button
        ATLButton(
          text: widget.isLoading ? l10n.registering : l10n.registerButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: Colors.white,
          textColor: ATLColors.darkBlue,
          outlineColor: ATLColors.darkBlue,
          onPressed: widget.isLoading ? () {} : widget.onRegister,
        ),
      ],
    );
  }
}
