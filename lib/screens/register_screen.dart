import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../widgets/atl_step_indicator.dart';
import '../widgets/atl_role_selector.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
import 'organization_contact_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1; // 1, 2 o 3
  UserRole? _selectedRole;

  // Controllers per Step 2
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _cityController;
  late final TextEditingController _birthdayController;

  // Controllers per Step 3
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  
  // Profile image
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _cityController = TextEditingController();
    _birthdayController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _cityController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _canProceedFromStep2() {
    return _nameController.text.trim().isNotEmpty &&
           _surnameController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty;
  }

  bool _canProceedFromStep3() {
    return _emailController.text.trim().isNotEmpty &&
           _usernameController.text.trim().isNotEmpty &&
           _passwordController.text.trim().isNotEmpty;
  }

  void _goToNextStep() {
    if (_currentStep == 2 && !_canProceedFromStep2()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compila tutti i campi obbligatori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }
  
  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      setState(() {
        _birthdayController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
  
  Future<void> _pickProfileImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).selectImageSource),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context).gallery),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context).camera),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );

        if (image != null) {
          setState(() {
            _profileImagePath = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _cancelAndGoBack() {
    Navigator.of(context).pop();
  }

  bool _isValidEmail(String email) {
    // Regex per validare l'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _register() {
    if (!_canProceedFromStep3()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Controllo email valida
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // TODO: Implement registration logic
    print('Registrazione: ruolo=$_selectedRole');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background color
          Container(
            decoration: const BoxDecoration(
              color: ATLColors.background,
            ),
          ),
          
          // Background image at the bottom
          Positioned(
            bottom: -100,
            left: 0,
            right: 0,
            child: Image.asset(
              'images/login_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.transparent,
                );
              },
            ),
          ),
          
          // Main content (scrollable)
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Step indicator
                    ATLStepIndicator(
                      totalSteps: 3,
                      currentStep: _currentStep,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Content based on current step
                    if (_currentStep == 1) _buildStep1(),
                    if (_currentStep == 2) _buildStep2(),
                    if (_currentStep == 3) _buildStep3(),
                    
                    const SizedBox(height: 30),
                    
                    // Bottom button (white/transparent)
                    if (_currentStep == 1 || _currentStep == 2)
                      ATLButton(
                        text: AppLocalizations.of(context).cancel,
                        size: ATLButtonSize.medium,
                        isFilled: true,
                        color: Colors.white,
                        textColor: Colors.black,
                        onPressed: _cancelAndGoBack,
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

  Widget _buildStep1() {
    return Column(
      children: [
        // Role selectors
        ATLRoleSelector(
          role: UserRole.coordinator,
          isSelected: _selectedRole == UserRole.coordinator,
          onTap: () {
            setState(() {
              _selectedRole = UserRole.coordinator;
            });
            _goToNextStep();
          },
        ),
        ATLRoleSelector(
          role: UserRole.player,
          isSelected: _selectedRole == UserRole.player,
          onTap: () {
            setState(() {
              _selectedRole = UserRole.player;
            });
            _goToNextStep();
          },
        ),
        ATLRoleSelector(
          role: UserRole.referee,
          isSelected: _selectedRole == UserRole.referee,
          onTap: () {
            setState(() {
              _selectedRole = UserRole.referee;
            });
            _goToNextStep();
          },
        ),
        ATLRoleSelector(
          role: UserRole.organization,
          isSelected: _selectedRole == UserRole.organization,
          onTap: () {
            // Naviga alla schermata di contatto per organizzazioni
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

  Widget _buildStep2() {
    return Column(
      children: [
        // Name *
        ATLTextField(
          controller: _nameController,
          hintText: '${AppLocalizations.of(context).name} *',
        ),
        
        const SizedBox(height: 16),
        
        // Surname *
        ATLTextField(
          controller: _surnameController,
          hintText: '${AppLocalizations.of(context).surname} *',
        ),
        
        const SizedBox(height: 16),
        
        // City * (TODO: make it a dropdown)
        ATLTextField(
          controller: _cityController,
          hintText: '${AppLocalizations.of(context).city} *',
        ),
        
        const SizedBox(height: 16),
        
        // Birthday (date picker)
        GestureDetector(
          onTap: _selectBirthday,
          child: AbsorbPointer(
            child: ATLTextField(
              controller: _birthdayController,
              hintText: AppLocalizations.of(context).birthday,
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Continue button
        ATLButton(
          text: AppLocalizations.of(context).continueButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.darkBlue,
          onPressed: _goToNextStep,
        ),
      ],
    );
  }

  Widget _buildStep3() {
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
                  image: _profileImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_profileImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profileImagePath == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      )
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
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Email *
        ATLTextField(
          controller: _emailController,
          hintText: '${AppLocalizations.of(context).email} *',
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 16),
        
        // Username *
        ATLTextField(
          controller: _usernameController,
          hintText: '${AppLocalizations.of(context).username} *',
        ),
        
        const SizedBox(height: 16),
        
        // Password *
        ATLTextField(
          controller: _passwordController,
          hintText: '${AppLocalizations.of(context).password} *',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: ATLColors.darkBlue,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Register button
        ATLButton(
          text: AppLocalizations.of(context).registerButton,
          size: ATLButtonSize.large,
          isFilled: true,
          color: ATLColors.darkBlue,
          onPressed: _register,
        ),
        
        const SizedBox(height: 16),
        
        // Undo button
        ATLButton(
          text: AppLocalizations.of(context).undo,
          size: ATLButtonSize.medium,
          isFilled: true,
          color: Colors.white,
          textColor: Colors.black,
          onPressed: _goToPreviousStep,
        ),
      ],
    );
  }
}
