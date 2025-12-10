import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'home_router.dart';
import '../providers/user_provider.dart';
import '../database/db_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

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

  void _handleLogin() async {
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

    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    // Replace mock user creation with DB call
    final User? user = await DB.Users.getByEmailOrUsername(usernameOrEmail, password);

    if (user == null || user.passwordMD5 != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidCredentials),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    switch (user.role) {
      case UserRole.coordinator:
        // Fetch and set coordinator-specific data if needed
        userProvider.setActiveUser(user, roleId: await DB.Coordinators.getById(user.id).then((c) => c!.coordinatorId));
        break;
      case UserRole.organization:
        // Fetch and set organization-specific data if needed
        //TODO: implementare repository Organization
        //userProvider.setActiveUser(user, roleId: await DB.Organizations.getById(user.id).then((o) => o!.organizationId));
        break;
      case UserRole.player:
        try {
          userProvider.setCurrentTeamId(await DB.PlaysAt.getTeamIdByPlayerId(user.id));
        } catch (e) {
          userProvider.setCurrentTeamId(-1);
        }
        userProvider.setActiveUser(user, roleId: await DB.Players.getById(user.id).then((p) => p!.playerId));
        break;
      case UserRole.guest:
        userProvider.setActiveUser(user);
        break;
      default:
        break;
    }

    print('Logged in as: ${user.username}, Team ID: ${userProvider.currentTeamId}');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeRouter.getHomeScreen(user),
      ),
    );
  }

  void _handleGuestUser() {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setActiveUser(User(
      id: 0,
      username: 'Guest',
      email: '',
      passwordMD5: '',
      role: UserRole.guest,
      firebaseUid: '',
      createdAt: DateTime.now(),
      balance: 0.0,
      phone: '',
    ));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeRouter.getHomeScreen(userProvider.activeUser!),
      ),
    );
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
                        _handleGuestUser();
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
