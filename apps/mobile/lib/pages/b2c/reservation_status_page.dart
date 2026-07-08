import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/reservations_provider.dart';
import '../../widgets/dev_badge.dart';

class ReservationStatusPage extends StatefulWidget {
  final Map<String, dynamic> reservation;
  
  const ReservationStatusPage({super.key, required this.reservation});

  @override
  State<ReservationStatusPage> createState() => _ReservationStatusPageState();
}

class _ReservationStatusPageState extends State<ReservationStatusPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = widget.reservation['status'] ?? 'pending';
    final token = widget.reservation['qr_code_token'];
    final offer = widget.reservation['offer'];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationConfirmed)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            if (status == 'confirmed' && token != null) ...[
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                l10n.reservationConfirmed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              Center(
                child: QrImageView(
                  data: token,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.showQrCode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (offer != null) ...[
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(offer['merchant']?['display_name'] ?? ''),
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              const Icon(Icons.payment, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                l10n.payNow,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              DevBadge(
                message: "Paiement simulé. En production, ceci redirigera vers l'interface SATIM/BaridiMob.",
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<ReservationsProvider>();
                    final session = await provider.initiatePayment(widget.reservation['id']);
                    if (session != null && session['payment_url'] != null) {
                      // TODO: Open WebView for BaridiMob payment
                    }
                  },
                  child: Text(l10n.payNow),
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
