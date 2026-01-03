import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isWaiting = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isWaiting = true;
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isWaiting = false;
          timer.cancel();
        }
      });
    });
  }

  void _sendPasswordResetEmail() {
    // TODO: Implement server request
    print('Invio email di recupero a: ${_emailController.text}');

    _startCountdown();
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
                          height: 200,
                          width: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 75,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Title text
                    Text(
                      AppLocalizations.of(context).forgotPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ATLColors.subtext,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Email TextField
                    ATLTextField(
                      controller: _emailController,
                      hintText: AppLocalizations.of(context).email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isWaiting,
                    ),

                    const SizedBox(height: 30),

                    // Send email button
                    ATLButton(
                      text: _isWaiting
                          ? 'Wait ${_secondsRemaining}s...'
                          : AppLocalizations.of(context).sendEmail,
                      size: ATLButtonSize.large,
                      isFilled: !_isWaiting,
                      color: ATLColors.darkBlue,
                      onPressed: _isWaiting ? () {} : _sendPasswordResetEmail,
                    ),

                    const SizedBox(height: 16),

                    // Cancel button
                    ATLButton(
                      text: AppLocalizations.of(context).cancel,
                      size: ATLButtonSize.medium,
                      isFilled: false,
                      color: ATLColors.darkBlue,
                      onPressed: () {
                        Navigator.of(context).pop();
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
