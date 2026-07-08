import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'otp_page.dart';

/// Login page with phone number input and language selection.
/// RTL applied immediately when Arabic is selected, before any login.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = auth.selectedLanguage == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo and title
              Icon(
                Icons.eco_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 40),

              // Language selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LanguageChip(
                    label: l10n.french,
                    isSelected: !isArabic,
                    onTap: () => auth.setLanguage('fr'),
                  ),
                  const SizedBox(width: 12),
                  _LanguageChip(
                    label: l10n.arabic,
                    isSelected: isArabic,
                    onTap: () => auth.setLanguage('ar'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Phone number input
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr, // Phone numbers always LTR
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumberLabel,
                    hintText: l10n.phoneNumberHint,
                    prefixIcon: const Icon(Icons.phone_android),
                    prefixText: '+213 ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isArabic ? 'يرجى إدخال رقم الهاتف' : 'Veuillez entrer un numéro';
                    }
                    if (!RegExp(r'^[567]\d{8}$').hasMatch(value.replaceAll(' ', ''))) {
                      return isArabic ? 'رقم هاتف غير صالح' : 'Numéro invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Error message
              if (auth.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final phone = '+213${_phoneController.text.replaceAll(' ', '')}';
                          final success = await auth.requestOtp(phone);
                          if (success && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtpPage(phoneNumber: phone),
                              ),
                            );
                          }
                        }
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.sendOtp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
