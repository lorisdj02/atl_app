import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sport.dart';
import '../utils/atl_colors.dart';

class AddRefereeLicenseDialog extends StatefulWidget {
  final List<Sport> availableSports;
  final int refereeId;
  final Future<bool> Function(int sportId, int refereeId, String id, DateTime issuedAt) onSubmit;

  const AddRefereeLicenseDialog({
    super.key,
    required this.availableSports,
    required this.refereeId,
    required this.onSubmit,
  });

  @override
  State<AddRefereeLicenseDialog> createState() => _AddRefereeLicenseDialogState();
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
            colorScheme: const ColorScheme.light(
              primary: ATLColors.darkBlue,
            ),
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport')),
      );
      return;
    }
    if (_issuedAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the issue date')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await widget.onSubmit(
        _selectedSport!.id,
        widget.refereeId,
        _idController.text.trim(),
        _issuedAt!,
      );
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add license. Try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                const Text(
                  'Add License',
                  style: TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // Sport dropdown
                const Text(
                  'Sport',
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
                      hint: const Text('Select sport'),
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
                const Text(
                  'Photo',
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
                      const SnackBar(
                        content: Text('Photo upload — Coming soon'),
                      ),
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
                          'Upload photo (coming soon)',
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
                const Text(
                  'License ID',
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
                    hintText: 'e.g. ABC-2024-001',
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
                      return 'Please enter the license ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Issue date picker
                const Text(
                  'Issued At',
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
                              : 'Select a date',
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
                        onPressed:
                            _isLoading ? null : () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
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
                            : const Text('Add'),
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
