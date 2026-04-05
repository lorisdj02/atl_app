import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/database/responses/login_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/account.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../utils/home_router.dart';
import '../providers/account_provider.dart';

// TODO: Rimuovi db_controller

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

    final AccountProvider userProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    // Replace mock user creation with DB call
    try{
    final LoginResponse loginData = await DBRead.handleLogin(usernameOrEmail, password);
    final Account? account = loginData.account;

    if (account == null || account.passwordMD5 != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidCredentials),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int? roleId = loginData.roleId;
    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidCredentials),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    userProvider.setActiveAccount(loginData.account!, roleId: roleId);

    if (loginData.account!.role == AccountRole.player) {
      final int? teamId = loginData.teamId;
      if (teamId != null) {
        userProvider.setCurrentTeamId(teamId);
      } else {
        userProvider.setCurrentTeamId(-1);
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeRouter.getHomeScreen(loginData.account!)),
    );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorGeneric(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleGuestUser() {
    final AccountProvider userProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    userProvider.setActiveAccount(
      Account(
        id: 0,
        username: AppLocalizations.of(context).guestUserLabel,
        email: '',
        passwordMD5: '',
        role: AccountRole.guest,
        firebaseUid: '',
        createdAt: DateTime.now(),
        phone: '',
        name: AppLocalizations.of(context).guestUserLabel,
        surname: '',
        birthdate: DateTime.now(),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            HomeRouter.getHomeScreen(userProvider.activeAccount!),
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
            decoration: const BoxDecoration(color: ATLColors.background),
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
                return Container(height: 300, color: Colors.transparent);
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
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 75,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Username or Email TextField
                    ATLTextField(
                      controller: _emailController,
                      hintText: AppLocalizations.of(context).usernameOrEmail,
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
