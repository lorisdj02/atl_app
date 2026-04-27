import 'package:atl_app/database/controller/field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/city.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/atl_button.dart';
import '../../database/db_read.dart';
import '../../l10n/app_localizations.dart';

class RegistrationScreenStep2 extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController phoneController;
  final String phonePrefix;
  final Function(String) onPhonePrefixChanged;
  final int? preferredCityId;
  final Function(int?) onCityChanged;
  final DateTime? birthday;
  final Function(DateTime) onBirthdayChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const RegistrationScreenStep2({
    super.key,
    required this.nameController,
    required this.surnameController,
    required this.phoneController,
    required this.phonePrefix,
    required this.onPhonePrefixChanged,
    required this.preferredCityId,
    required this.onCityChanged,
    required this.birthday,
    required this.onBirthdayChanged,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<RegistrationScreenStep2> createState() =>
      _RegistrationScreenStep2State();
}

class _RegistrationScreenStep2State extends State<RegistrationScreenStep2> {
  List<City> _cities = [];
  bool _loadingCities = true;

  static const List<String> _phonePrefixes = [
    '+39',
    '+1',
    '+44',
    '+33',
    '+49',
    '+34',
    '+351',
    '+41',
    '+32',
    '+31',
  ];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await FieldController.Read.getAllCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _loadingCities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: ATLColors.darkBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) widget.onBirthdayChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Name *
        ATLTextField(
          controller: widget.nameController,
          hintText: l10n.nameRequired,
        ),

        const SizedBox(height: 16),

        // Surname *
        ATLTextField(
          controller: widget.surnameController,
          hintText: l10n.surnameRequired,
        ),

        const SizedBox(height: 16),

        // Phone (prefix + number)
        _buildPhoneField(),

        const SizedBox(height: 16),

        // Birthday * (mandatory)
        GestureDetector(
          onTap: _selectBirthday,
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: ATLColors.darkBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.birthday == null
                        ? l10n.birthdayRequired
                        : '${widget.birthday!.day.toString().padLeft(2, '0')}/'
                              '${widget.birthday!.month.toString().padLeft(2, '0')}/'
                              '${widget.birthday!.year}',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.birthday == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Preferred city (optional)
        _buildCityDropdown(),

        const SizedBox(height: 30),

        ATLButton(
          text: l10n.continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.darkBlue,
          onPressed: widget.onContinue,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Prefix dropdown
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.phonePrefix,
                items: _phonePrefixes
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 15,
                            color: ATLColors.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) widget.onPhonePrefixChanged(v);
                },
              ),
            ),
          ),
          // Number field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: widget.phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.enterPhone,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    final l10n = AppLocalizations.of(context);
    if (_loadingCities) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<int>(
        value: widget.preferredCityId,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(
          l10n.preferredCityOptional,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        items: _cities
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            .toList(),
        onChanged: widget.onCityChanged,
      ),
    );
  }
}
