import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../providers/user_provider.dart';
import '../../database/db_controller.dart';
import '../../widgets/atl_textfield.dart';

class SettingsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const SettingsScreen({super.key, required this.currentSport});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'English';
  bool _autoPlayVideos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Notifications Section
          const _SectionHeader(title: 'Notifications'),
          _SettingTile(
            icon: Icons.notifications,
            title: 'Enable Notifications',
            subtitle: 'Receive notifications about matches and tournaments',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                // TODO: Save preference
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings will be saved soon')),
                );
              },
              activeThumbColor: ATLColors.getPrimaryColor(widget.currentSport),
            ),
          ),
          if (_notificationsEnabled) ...[
            _SettingTile(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              trailing: Switch(
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
                activeThumbColor: ATLColors.getPrimaryColor(
                  widget.currentSport,
                ),
              ),
            ),
            _SettingTile(
              icon: Icons.phone_android,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              trailing: Switch(
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
                activeThumbColor: ATLColors.getPrimaryColor(
                  widget.currentSport,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Appearance Section
          const _SectionHeader(title: 'Appearance'),
          _SettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                // TODO: Implement dark mode
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark mode coming soon')),
                );
              },
              activeThumbColor: ATLColors.getPrimaryColor(widget.currentSport),
            ),
          ),
          _SettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _language,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),

          const SizedBox(height: 24),

          // Privacy & Security Section
          const _SectionHeader(title: 'Privacy & Security'),
          _SettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          _SettingTile(
            icon: Icons.security,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show terms
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),

          // App Preferences Section
          const _SectionHeader(title: 'App Preferences'),
          _SettingTile(
            icon: Icons.play_circle,
            title: 'Auto-play Videos',
            subtitle: 'Automatically play videos in feed',
            trailing: Switch(
              value: _autoPlayVideos,
              onChanged: (value) {
                setState(() => _autoPlayVideos = value);
              },
              activeThumbColor: ATLColors.getPrimaryColor(widget.currentSport),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          const _SectionHeader(title: 'About'),
          _SettingTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: const SizedBox(),
          ),
          _SettingTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help with the app',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon')),
              );
            },
          ),
          _SettingTile(
            icon: Icons.rate_review,
            title: 'Rate Us',
            subtitle: 'Rate us on the app store',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Open app store
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate us coming soon')),
              );
            },
          ),

          const SizedBox(height: 24),

          // Danger Zone
          const _SectionHeader(title: 'Danger Zone'),
          _SettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: Colors.red,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red,
            ),
            onTap: () async {
              final confirmed = await _showDeleteAccountDialog();
              if (confirmed && mounted) {
                await _handleDeletion();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              language: 'English',
              isSelected: _language == 'English',
              onTap: () {
                setState(() => _language = 'English');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              language: 'Italiano',
              isSelected: _language == 'Italiano',
              onTap: () {
                setState(() => _language = 'Italiano');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language support coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: ATLColors.subtext),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please enter your password to confirm:',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ATLTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final password = passwordController.text;

              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final user = userProvider.activeUser;

              if (user == null) {
                Navigator.pop(context, false);
                return;
              }

              // Check if password matches
              if (user.passwordMD5 != password) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Password is correct, close dialog and confirm
              Navigator.pop(context, true);
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _handleDeletion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;

    if (user == null) return;

    // Delete account
    final success = await DBWrite.deleteAccount(user.id, user.passwordMD5!);

    if (success) {
      // Logout user
      await userProvider.logout();

      if (mounted) {
        // Navigate back to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to delete account. Check if your owned teams have Vice Captains assigned.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: ATLColors.darkBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? ATLColors.darkBlue),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? ATLColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ATLColors.subtext, fontSize: 12),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: onTap,
    );
  }
}
