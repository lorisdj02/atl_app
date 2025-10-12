import 'package:flutter/material.dart';
import '../widgets/atl_button.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

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
                    
                    // Email TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).email,
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 16,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).password,
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 16,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
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
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot password link
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
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
                    
                    const SizedBox(height: 20),
                    
                    // Log in button
                    ATLButton(
                      text: AppLocalizations.of(context).logIn,
                      size: ATLButtonSize.large,
                      isFilled: true,
                      color: ATLColors.darkBlue,
                      onPressed: () {
                        // TODO: Implement login logic
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Register button
                    ATLButton(
                      text: AppLocalizations.of(context).register,
                      size: ATLButtonSize.medium,
                      isFilled: false,
                      color: ATLColors.darkBlue,
                      onPressed: () {
                        // TODO: Implement register navigation
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Continue as guest button
                    ATLButton(
                      text: AppLocalizations.of(context).continueAsGuest,
                      size: ATLButtonSize.small,
                      isFilled: false,
                      color: ATLColors.darkBlue,
                      onPressed: () {
                        // TODO: Implement guest navigation
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
