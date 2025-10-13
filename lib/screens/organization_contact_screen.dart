import 'package:flutter/material.dart';
import '../widgets/atl_button.dart';
import '../widgets/atl_textfield.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

class OrganizationContactScreen extends StatefulWidget {
  const OrganizationContactScreen({super.key});

  @override
  State<OrganizationContactScreen> createState() => _OrganizationContactScreenState();
}

class _OrganizationContactScreenState extends State<OrganizationContactScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Rimuove spazi, trattini e parentesi
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Accetta numeri con prefisso internazionale (+39, +1, etc) o senza
    // Minimo 8 cifre, massimo 15 cifre
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  Future<void> _sendContactMessage() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    // Validazione campi obbligatori
    if (email.isEmpty || phone.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).fillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validazione email
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validazione numero di telefono
    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidPhone),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementare l'invio email al server
    // Simulazione invio
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Mostra messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).messageSentSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Torna al login dopo un breve delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Pop fino al login (rimuove tutte le schermate intermedie)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
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
                    
                    // Three dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true),
                        const SizedBox(width: 8),
                        _buildDot(true),
                        const SizedBox(width: 8),
                        _buildDot(true), // Terzo step attivo
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Email TextField
                    ATLTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone TextField
                    ATLTextField(
                      controller: _phoneController,
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Message TextField (multiline)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Your message',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: ATLColors.darkBlue,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contact us button
                    ATLButton(
                      text: 'Contact us!',
                      size: ATLButtonSize.large,
                      isFilled: true,
                      color: ATLColors.darkBlue,
                      onPressed: _sendContactMessage,
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

  Widget _buildDot(bool isActive) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? ATLColors.darkBlue : Colors.transparent,
        border: Border.all(
          color: ATLColors.darkBlue,
          width: 2,
        ),
      ),
    );
  }
}
