import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'consent_page.dart';

/// OTP verification screen with countdown timer and resend logic.
class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  int _resendCooldown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.sms_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.otpMessage(widget.phoneNumber),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            // OTP input — always LTR for digits
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
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
            ElevatedButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.verifyOtp(
                        widget.phoneNumber,
                        _otpController.text,
                      );
                      if (success && mounted) {
                        if (auth.isNewUser) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConsentPage(),
                            ),
                          );
                        } else {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
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
                  : Text(l10n.verifyOtp),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _canResend
                  ? () {
                      auth.requestOtp(widget.phoneNumber);
                      _startCooldown();
                    }
                  : null,
              child: Text(
                _canResend
                    ? l10n.resendOtp
                    : '${l10n.resendOtp} ($_resendCooldown s)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
