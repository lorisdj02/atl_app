import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/atl_textfield.dart';
import '../../l10n/app_localizations.dart';

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

  String _languageDisplayName(AppLocalizations l10n) {
    // Keep internal values stable for comparisons, localize only what's displayed.
    if (_language == 'Italiano') return l10n.italianLanguage;
    return l10n.englishLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
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
          _SectionHeader(title: l10n.notifications),
          _SettingTile(
            icon: Icons.notifications,
            title: l10n.enableNotifications,
            subtitle: l10n.enableNotificationsSubtitle,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                // TODO: Save preference
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsSavedSoon)),
                );
              },
              activeThumbColor: ATLColors.getPrimaryColor(widget.currentSport),
            ),
          ),
          if (_notificationsEnabled) ...[
            _SettingTile(
              icon: Icons.email,
              title: l10n.emailNotifications,
              subtitle: l10n.emailNotificationsSubtitle,
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
              title: l10n.pushNotifications,
              subtitle: l10n.pushNotificationsSubtitle,
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
          _SectionHeader(title: l10n.appearance),
          _SettingTile(
            icon: Icons.dark_mode,
            title: l10n.darkModeLabel,
            subtitle: l10n.darkModeSubtitle,
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                // TODO: Implement dark mode
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
                );
              },
              activeThumbColor: ATLColors.getPrimaryColor(widget.currentSport),
            ),
          ),
          _SettingTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _languageDisplayName(l10n),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),

          const SizedBox(height: 24),

          // Privacy & Security Section
          _SectionHeader(title: l10n.privacySecurity),
          _SettingTile(
            icon: Icons.privacy_tip,
            title: l10n.privacyPolicy,
            subtitle: l10n.privacyPolicySubtitle,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.privacyComingSoon)),
              );
            },
          ),
          _SettingTile(
            icon: Icons.security,
            title: l10n.termsOfService,
            subtitle: l10n.termsOfServiceSubtitle,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show terms
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.termsComingSoon)),
              );
            },
          ),

          const SizedBox(height: 24),

          // App Preferences Section
          _SectionHeader(title: l10n.appPreferences),
          _SettingTile(
            icon: Icons.play_circle,
            title: l10n.autoPlayVideos,
            subtitle: l10n.autoPlayVideosSubtitle,
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
          _SectionHeader(title: l10n.about),
          _SettingTile(
            icon: Icons.info,
            title: l10n.appVersion,
            subtitle: '1.0.0',
            trailing: const SizedBox(),
          ),
          _SettingTile(
            icon: Icons.help,
            title: l10n.helpAndSupport,
            subtitle: l10n.helpAndSupportSubtitle,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show help
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.helpComingSoon)),
              );
            },
          ),
          _SettingTile(
            icon: Icons.rate_review,
            title: l10n.rateUs,
            subtitle: l10n.rateUsSubtitle,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Open app store
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.rateUsComingSoon)),
              );
            },
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _SectionHeader(title: l10n.dangerZone),
          _SettingTile(
            icon: Icons.delete_forever,
            title: l10n.deleteAccount,
            subtitle: l10n.deleteAccountSubtitle,
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              languageLabel: l10n.englishLanguage,
              isSelected: _language == 'English',
              onTap: () {
                setState(() => _language = 'English');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              languageLabel: l10n.italianLanguage,
              isSelected: _language == 'Italiano',
              onTap: () {
                setState(() => _language = 'Italiano');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.languageComingSoon)),
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
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.deleteAccountTitle,
          style: const TextStyle(color: Colors.red),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountWarning,
                style: const TextStyle(color: ATLColors.subtext),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pleaseEnterPassword,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ATLTextField(
                controller: passwordController,
                hintText: l10n.enterYourPassword,
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
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final password = passwordController.text;

              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pleaseEnterPassword),
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
                  SnackBar(
                    content: Text(l10n.incorrectPassword),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Password is correct, close dialog and confirm
              Navigator.pop(context, true);
            },
            child: Text(
              l10n.deleteAccountButton,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteAccount),
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
  final String languageLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(languageLabel),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: onTap,
    );
  }
}
