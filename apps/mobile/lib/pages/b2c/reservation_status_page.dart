import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dev_badge.dart';
import '../../widgets/info_tooltip.dart';

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
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                l10n.reservationConfirmed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(data: token, version: QrVersions.auto, size: 200.0),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.showQrCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  InfoTooltip(
                    title: 'Pourquoi un QR code ?',
                    body: 'Ce code confirme votre identité et votre commande auprès du '
                        'commerçant. Il le scanne à votre arrivée pour valider la remise '
                        'du panier — pas besoin de montrer autre chose.',
                  ),
                ],
              ),
              if (offer != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('🛍️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer['title'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(offer['merchant']?['display_name'] ?? '',
                                  style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              const Text('💳', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                l10n.payNow,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paymentWaitingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 32),
              DevBadge(
                message:
                    "Paiement simulé. En production, ceci redirigera vers l'interface SATIM/BaridiMob.",
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