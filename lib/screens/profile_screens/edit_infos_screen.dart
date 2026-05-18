import 'dart:io';

import 'package:atl_app/database/services/account_service.dart';
import 'package:atl_app/database/services/field_service.dart';
import 'package:atl_app/database/requests/update_account_info_request.dart';
import 'package:atl_app/models/account.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/city.dart';
import '../../models/enums/sport_category.dart';
import '../../models/player.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/info_row_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/profile_image.dart';

class EditInfosScreen extends StatefulWidget {
  final SportCategory currentSport;

  const EditInfosScreen({super.key, required this.currentSport});

  @override
  State<EditInfosScreen> createState() => _EditInfosScreenState();
}

class _EditInfosScreenState extends State<EditInfosScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _accountnameController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _showPasswordFields = false;

  File? _selectedProfileImage;
  bool _preferredCityTouched = false;

  List<City> _cities = [];
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    final account = Provider.of<AccountProvider>(
      context,
      listen: false,
    ).activeAccount;

    _accountnameController = TextEditingController(text: account?.username ?? '');
    _phoneController = TextEditingController(text: account?.phone ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();

    // Add listeners to detect changes
    _accountnameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _oldPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);

    _loadCities();
  }

  Future<void> _loadCities() async {
    final account = Provider.of<AccountProvider>(
      context,
      listen: false,
    ).activeAccount;
    try {
      final List<City> cities = await FieldService.getAllCities();
      if (mounted) {
        City? currentCity;
        if (account?.preferredCityId != null) {
          try {
            currentCity = cities.firstWhere(
              (c) => c.id == account!.preferredCityId,
            );
          } catch (_) {}
        }
        setState(() {
          _cities = cities;
          _selectedCity = currentCity;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingCities(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

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

    if (source == null) return;

    final XFile? image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() {
      _selectedProfileImage = File(image.path);
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _accountnameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final account = accountProvider.activeAccount;
    if (account == null) return;

    // Validate password fields if changing password
    if (_oldPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty) {
      if (_oldPasswordController.text.isEmpty) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.enterCurrentPassword),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_newPasswordController.text.isEmpty) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.enterNewPassword),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_newPasswordController.text.length < 6) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.newPasswordMinLength),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if old password matches
      // TODO: verifica
      /*  if (account.passwordMD5 != _oldPasswordController.text) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.currentPasswordIncorrect),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } */
    }

    setState(() => _isLoading = true);

    try {
      UpdateAccountInfoRequest request = UpdateAccountInfoRequest(
        username: _accountnameController.text != account.username
            ? _accountnameController.text
            : null,
        phone: _phoneController.text != account.phone
            ? _phoneController.text
            : null,
        // If the dropdown shows the hint ('Seleziona città'), _selectedCity is null
        // and we send null to clear the preferred city. Otherwise send the selected id.
        preferredCityId: _selectedCity?.id,
        preferredCityTouched: _preferredCityTouched,
        birthdate: null, // Non modificabile in questa schermata
        imageUrl: null,
      );
      // Update account info through repository
      final Account? data = await AccountService.updateAccountInfos(
        request,
        profileImage: _selectedProfileImage,
      );

      if (data == null) {
        throw Exception('Failed to update account info');
      }

      // Retrieve updated account from repository
      final updatedaccount = data;

      // Update AccountProvider
      await accountProvider.updateAccount(updatedaccount);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _hasChanges = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _showPasswordFields = false;
          _selectedProfileImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUpdatingProfile(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).activeAccount;
    final isPlayer = account is Player;
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
          l10n.editProfileTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    ProfileImage(
                      account: account,
                      currentSport: widget.currentSport,
                      radius: 60,
                      localFile: _selectedProfileImage,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: ATLColors.getPrimaryColor(
                            widget.currentSport,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Editable Information Section
              Text(
                l10n.editableInformation,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel(l10n.usernameLabel),
              ATLTextField(
                controller: _accountnameController,
                hintText: l10n.enterUsername,
              ),
              const SizedBox(height: 16),

              _buildLabel(l10n.phoneLabel),
              ATLTextField(
                controller: _phoneController,
                hintText: l10n.enterPhone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),
              _buildLabel(l10n.preferredCityLabel),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ATLColors.subtext.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<City>(
                    value: _selectedCity,
                    hint: Text(
                      l10n.selectCityText,
                      style: const TextStyle(color: ATLColors.subtext),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: ATLColors.darkBlue,
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem<City>(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _preferredCityTouched = true;
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Change Password Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.changePassword,
                    style: const TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showPasswordFields
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: ATLColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPasswordFields = !_showPasswordFields;
                        if (!_showPasswordFields) {
                          _oldPasswordController.clear();
                          _newPasswordController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),

              if (_showPasswordFields) ...[
                const SizedBox(height: 16),
                _buildLabel(l10n.currentPasswordLabel),
                ATLTextField(
                  controller: _oldPasswordController,
                  hintText: l10n.enterCurrentPasswordHint,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildLabel(l10n.newPasswordLabel),
                ATLTextField(
                  controller: _newPasswordController,
                  hintText: l10n.enterNewPasswordHint,
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 32),

              // Account Details (Read-only)
              Text(
                l10n.accountDetails,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              InfoRowWidget(
                label: l10n.emailLabel,
                value: account?.email ?? l10n.notAvailable,
              ),
              if (isPlayer) ...[
                InfoRowWidget(label: l10n.nameLabel, value: account!.name),
                InfoRowWidget(label: l10n.surnameLabel, value: account.surname),
                InfoRowWidget(
                  label: l10n.birthDateLabel,
                  value: _formatDate(l10n, account.birthdate),
                ),
              ],
              InfoRowWidget(
                label: l10n.roleLabel,
                value: account?.roleDisplayName ?? l10n.notAvailable,
              ),
              InfoRowWidget(
                label: l10n.memberSinceLabel,
                value: _formatDate(l10n, account?.createdAt),
              ),
              InfoRowWidget(
                label: l10n.vipStatusLabel,
                value: account?.isVip == true ? l10n.active : l10n.inactive,
              ),

              const SizedBox(height: 32),

              // Save Button
              ATLButton(
                text: _isLoading ? l10n.savingText : l10n.saveChanges,
                size: ATLButtonSize.large,
                isFilled: true,
                color: _hasChanges ? ATLColors.darkBlue : ATLColors.subtext,
                fullWidth: true,
                onPressed: _hasChanges && !_isLoading ? _saveChanges : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: ATLColors.darkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime? date) {
    if (date == null) return l10n.notAvailable;
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPlaceholder(Account? account) {
    final color = ATLColors.getPrimaryColor(widget.currentSport);
    String? initials;
    if (account != null) {
      final parts = '${account.name ?? ''} ${account.surname ?? ''}'
          .trim()
          .split(RegExp(r"\s+"));
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (initials == null || initials.isEmpty) {
        initials = (account.username ?? '')
            .trim()
            .split(RegExp(r"\s+"))
            .where((s) => s.isNotEmpty)
            .map((s) => s[0])
            .take(2)
            .join()
            .toUpperCase();
      }
    }

    if (initials != null && initials.isNotEmpty) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: color,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(
      Icons.person,
      color: color,
      size: 60,
    );
  }

  ImageProvider<Object>? _getProfileImageProvider(Account? account) {
    return null;
  }
}
