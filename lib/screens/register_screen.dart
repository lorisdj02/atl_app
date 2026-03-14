import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/atl_colors.dart';
import '../database/db_write.dart';
import 'registration/registration_screen_step1.dart';
import 'registration/registration_screen_step2.dart';
import 'registration/registration_screen_step3.dart';
import '../../widgets/atl_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  UserRole? _selectedRole;
  bool _isRegistering = false;

  // Step 2 data
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _phonePrefix = '+39';
  int? _preferredCityId;
  DateTime? _birthday;

  // Step 3 data
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  String? _profileImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step > _currentStep) return; // can only go back or stay
    setState(() {
      if (step == 1) {
        // Clear all fields when returning to step 1
        _selectedRole = null;
        _nameController.clear();
        _surnameController.clear();
        _phoneController.clear();
        _phonePrefix = '+39';
        _preferredCityId = null;
        _birthday = null;
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _inviteCodeController.clear();
        _profileImagePath = null;
      }
      _currentStep = step;
    });
  }

  void _goToNextStep() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  Future<void> _register() async {
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthday.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isRegistering = true);
    try {
      final success = await DBWrite.registerUser(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        role: _selectedRole!,
        phone: '$_phonePrefix${_phoneController.text.trim()}',
        birthdate: _birthday!,
        inviteCode: _inviteCodeController.text.trim().isEmpty
            ? null
            : _inviteCodeController.text.trim(),
        profilePictureUrl: _profileImagePath,
      );
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: ATLColors.background),
          ),

          Positioned(
            bottom: -100,
            left: 0,
            right: 0,
            child: Image.asset(
              'images/login_background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 300, color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Logo
                    Image.asset(
                      'images/logo_vertical.png',
                      height: 150,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tappable step indicator
                    _buildStepIndicator(),

                    const SizedBox(height: 30),

                    // Step content
                    if (_currentStep == 1)
                      RegistrationScreenStep1(
                        selectedRole: _selectedRole,
                        onRoleSelected: (role) {
                          setState(() => _selectedRole = role);
                          _goToNextStep();
                        },
                      ),
                    if (_currentStep == 2)
                      RegistrationScreenStep2(
                        nameController: _nameController,
                        surnameController: _surnameController,
                        phoneController: _phoneController,
                        phonePrefix: _phonePrefix,
                        onPhonePrefixChanged: (p) =>
                            setState(() => _phonePrefix = p),
                        preferredCityId: _preferredCityId,
                        onCityChanged: (id) =>
                            setState(() => _preferredCityId = id),
                        birthday: _birthday,
                        onBirthdayChanged: (d) => setState(() => _birthday = d),
                        onContinue: _goToNextStep,
                        onBack: () => _goToStep(1),
                      ),
                    if (_currentStep == 3)
                      RegistrationScreenStep3(
                        emailController: _emailController,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        inviteCodeController: _inviteCodeController,
                        profileImagePath: _profileImagePath,
                        onProfileImageChanged: (p) =>
                            setState(() => _profileImagePath = p),
                        onRegister: _register,
                        onBack: () => _goToStep(2),
                        isLoading: _isRegistering,
                      ),

                    const SizedBox(height: 30),

                    if (_currentStep == 1)
                      ATLButton(
                        text: 'Continue',
                        size: ATLButtonSize.medium,
                        isFilled: true,
                        color: Colors.white,
                        textColor: ATLColors.darkBlue,
                        outlineColor: ATLColors.darkBlue,
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = step <= _currentStep;
        final isTappable = step < _currentStep;
        return GestureDetector(
          onTap: isTappable ? () => _goToStep(step) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive ? ATLColors.darkBlue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: ATLColors.darkBlue, width: 3),
              ),
              child: isTappable
                  ? const Icon(Icons.arrow_back, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
