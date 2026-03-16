import 'package:flutter/material.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/atl_button.dart';
import '../../l10n/app_localizations.dart';

class ContactUsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const ContactUsScreen({super.key, required this.currentSport});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Inquiry',
    'Technical Issue',
    'Account Problem',
    'Payment Issue',
    'Feature Request',
    'Report Bug',
    'Other',
  ];

  String _categoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case 'General Inquiry':
        return l10n.generalInquiry;
      case 'Technical Issue':
        return l10n.technicalIssue;
      case 'Account Problem':
        return l10n.accountProblem;
      case 'Payment Issue':
        return l10n.paymentIssue;
      case 'Feature Request':
        return l10n.featureRequest;
      case 'Report Bug':
        return l10n.reportBug;
      case 'Other':
      default:
        return l10n.other;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement actual API call to send message
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.messageSentSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _subjectController.clear();
        _messageController.clear();
        setState(() => _selectedCategory = 'General Inquiry');

        // Go back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSendingMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.contactUsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: ATLColors.getPrimaryColor(
                        widget.currentSport,
                      ).withOpacity(0.2),
                      child: Icon(
                        Icons.mail_outline,
                        color: ATLColors.getPrimaryColor(widget.currentSport),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.getInTouch,
                      style: const TextStyle(
                        color: ATLColors.darkBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getInTouchSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ATLColors.subtext, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Contact Options
              Row(
                children: [
                  Expanded(
                    child: _QuickContactCard(
                      icon: Icons.email,
                      label: l10n.emailLabel,
                      value: 'support@atl.com',
                      color: ATLColors.darkBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickContactCard(
                      icon: Icons.phone,
                      label: l10n.phoneLabel,
                      value: '+39 123 456 789',
                      color: ATLColors.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Category Selection
              Text(
                l10n.categoryLabel,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_categoryLabel(l10n, category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Subject
              Text(
                l10n.subjectLabel,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ATLTextField(
                controller: _subjectController,
                hintText: l10n.enterSubject,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                l10n.messageLabel,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: l10n.typeYourMessage,
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ATLButton(
                text: _isSubmitting ? l10n.sendingText : l10n.sendMessage,
                size: ATLButtonSize.large,
                isFilled: true,
                color: ATLColors.darkBlue,
                fullWidth: true,
                onPressed: _isSubmitting ? () {} : _submitForm,
              ),
              const SizedBox(height: 16),

              // FAQ Link
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to FAQ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.faqComingSoon)),
                    );
                  },
                  child: Text(
                    l10n.checkOurFaq,
                    style: TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ATLColors.subtext, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
