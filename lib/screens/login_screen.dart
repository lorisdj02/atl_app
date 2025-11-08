import 'package:flutter/material.dart';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../models/player.dart';
import '../models/coordinator.dart';
import '../models/referee.dart';
import '../models/organization.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'home_router.dart';
import 'guest/guest_home_screen.dart';
import 'package:atl_app/models/sport_category.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.player; // DEBUG: Role selector

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final usernameOrEmail = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Controllo campi vuoti
    if (usernameOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement login logic with server
    // PLACEHOLDER: Crea un mock user basato sul ruolo selezionato
    final User mockUser;
    
    switch (_selectedRole) {
      case UserRole.player:
        mockUser = Player(
          id: 1,
          username: 'TestPlayer',
          email: usernameOrEmail,
          firebaseUid: 'mock_firebase_uid',
          createdAt: DateTime.now(),
          balance: 0.0,
          phone: '1234567890',
          playerId: 1,
          name: 'Test',
          surname: 'Player',
          birthdate: DateTime(2000, 1, 1),
        );
        break;
      case UserRole.coordinator:
        mockUser = Coordinator(
          id: 1,
          username: 'TestCoordinator',
          email: usernameOrEmail,
          firebaseUid: 'mock_firebase_uid',
          createdAt: DateTime.now(),
          balance: 0.0,
          phone: '1234567890',
          coordinatorId: 1,
          name: 'Test',
          surname: 'Coordinator',
          level: 1,
        );
        break;
      case UserRole.referee:
        mockUser = Referee(
          id: 1,
          username: 'TestReferee',
          email: usernameOrEmail,
          firebaseUid: 'mock_firebase_uid',
          createdAt: DateTime.now(),
          balance: 0.0,
          phone: '1234567890',
          refereeId: 1,
          name: 'Test',
          surname: 'Referee',
          level: 1,
        );
        break;
      case UserRole.organization:
        mockUser = Organization(
          id: 1,
          username: 'TestOrganization',
          email: usernameOrEmail,
          firebaseUid: 'mock_firebase_uid',
          createdAt: DateTime.now(),
          balance: 0.0,
          phone: '1234567890',
          organizationId: 1,
          orgName: 'Test Organization',
          name: 'Test',
          surname: 'Admin',
        );
        break;
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeRouter.getHomeScreen(mockUser),
      ),
    );
  }

  // DEBUG: Helper methods for role selector
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.player:
        return Icons.person;
      case UserRole.coordinator:
        return Icons.admin_panel_settings;
      case UserRole.referee:
        return Icons.sports_soccer;
      case UserRole.organization:
        return Icons.business;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.player:
        return 'Player';
      case UserRole.coordinator:
        return 'Coordinator';
      case UserRole.referee:
        return 'Referee';
      case UserRole.organization:
        return 'Organization';
    }
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
            bottom: 0,
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
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 256,
                          width: 256,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 75),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Username or Email TextField
                    ATLTextField(
                      controller: _emailController,
                      hintText: 'Username or Email',
                      keyboardType: TextInputType.text,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password TextField
                    ATLTextField(
                      controller: _passwordController,
                      hintText: AppLocalizations.of(context).password,
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
                    
                    const SizedBox(height: 16),
                    
                    // DEBUG: Role selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ATLColors.darkBlue, width: 2),
                      ),
                      child: DropdownButton<UserRole>(
                        value: _selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: ATLColors.darkBlue),
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        items: UserRole.values.map((UserRole role) {
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child: Row(
                              children: [
                                Icon(
                                  _getRoleIcon(role),
                                  color: ATLColors.darkBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text('DEBUG: ${_getRoleName(role)}'),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (UserRole? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Forgot password link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).forgotPassword,
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Log in button
                    ATLButton(
                      text: AppLocalizations.of(context).logIn,
                      size: ATLButtonSize.large,
                      isFilled: true,
                      color: ATLColors.darkBlue,
                      onPressed: _handleLogin,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Register button
                    ATLButton(
                      text: AppLocalizations.of(context).register,
                      size: ATLButtonSize.medium,
                      isFilled: false,
                      color: ATLColors.darkBlue,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 56),
                    
                    // Continue as guest button - BIANCO e SMALL
                    ATLButton(
                      text: AppLocalizations.of(context).continueAsGuest,
                      size: ATLButtonSize.small,
                      isFilled: false,
                      color: ATLColors.darkBlue,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const GuestHomeScreen(currentSport: SportCategory.football),
                          ),
                        );
                      },
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
}
