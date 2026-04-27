import 'package:atl_app/models/referee_license.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sport.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

class AddRefereeLicenseDialog extends StatefulWidget {
  final List<Sport> availableSports;
  final int refereeId;
  final Future<RefereeLicense> Function(RefereeLicense license) onSubmit;

  const AddRefereeLicenseDialog({
    super.key,
    required this.availableSports,
    required this.refereeId,
    required this.onSubmit,
  });

  @override
  State<AddRefereeLicenseDialog> createState() =>
      _AddRefereeLicenseDialogState();
}

class _AddRefereeLicenseDialogState extends State<AddRefereeLicenseDialog> {
  Sport? _selectedSport;
  final TextEditingController _idController = TextEditingController();
  DateTime? _issuedAt;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1970),
      lastDate: now, // Only past dates
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: ATLColors.darkBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _issuedAt = picked);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSport == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectSportFirst2)));
      return;
    }
    if (_issuedAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectIssueDate)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final license = await widget.onSubmit(
        RefereeLicense(
          sportId: _selectedSport!.id,
          refereeId: widget.refereeId,
          id: _idController.text.trim(),
          issuedAt: _issuedAt!,
          status: LicenseStatus.notVerified,
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(license);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  l10n.addLicenseTitle,
                  style: TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // Sport dropdown
                Text(
                  l10n.sportLabel,
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ATLColors.subtext.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Sport>(
                      value: _selectedSport,
                      hint: Text(l10n.selectSport),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: ATLColors.darkBlue,
                      ),
                      items: widget.availableSports.map((sport) {
                        return DropdownMenuItem<Sport>(
                          value: sport,
                          child: Text(sport.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSport = value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Photo placeholder (TODO: implement actual photo picker)
                Text(
                  l10n.photoLabel,
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // TODO: Replace with actual image picker
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.photoUploadComingSoon)),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ATLColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ATLColors.subtext.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: ATLColors.subtext.withOpacity(0.5),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.uploadPhotoComingSoon,
                          style: TextStyle(
                            color: ATLColors.subtext.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // License identifier
                Text(
                  l10n.licenseIdLabel,
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    hintText: l10n.licenseIdHint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: ATLColors.subtext.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: ATLColors.subtext.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: ATLColors.darkBlue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterLicenseId;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Issue date picker
                Text(
                  l10n.issuedAtLabel,
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ATLColors.subtext.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: ATLColors.darkBlue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _issuedAt != null
                              ? dateFormat.format(_issuedAt!)
                              : l10n.selectADate,
                          style: TextStyle(
                            color: _issuedAt != null
                                ? ATLColors.subtext
                                : ATLColors.subtext.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(
                          l10n.cancelButton,
                          style: TextStyle(color: ATLColors.subtext),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ATLColors.darkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.addButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
