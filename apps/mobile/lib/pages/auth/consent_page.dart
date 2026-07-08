import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

/// Granular consent screen — three separate toggles, never a global checkbox.
/// Required before account creation per Loi 18-07.
class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _paymentConsent = false;
  bool _geolocationConsent = false;
  bool _notificationConsent = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consentTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.shield_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            // Payment consent
            _ConsentToggle(
              icon: Icons.payment,
              title: l10n.consentPayment,
              description: l10n.consentPaymentDesc,
              value: _paymentConsent,
              onChanged: (v) => setState(() => _paymentConsent = v),
            ),
            const Divider(),
            // Geolocation consent
            _ConsentToggle(
              icon: Icons.location_on,
              title: l10n.consentGeolocation,
              description: l10n.consentGeolocationDesc,
              value: _geolocationConsent,
              onChanged: (v) => setState(() => _geolocationConsent = v),
            ),
            const Divider(),
            // Notification consent
            _ConsentToggle(
              icon: Icons.notifications,
              title: l10n.consentNotifications,
              description: l10n.consentNotificationsDesc,
              value: _notificationConsent,
              onChanged: (v) => setState(() => _notificationConsent = v),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await auth.updateConsent(
                  payment: _paymentConsent,
                  geolocation: _geolocationConsent,
                  notifications: _notificationConsent,
                );
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Text(l10n.continueButton),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentToggle({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
