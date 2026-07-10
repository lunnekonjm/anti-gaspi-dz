import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SponsoringPage extends StatelessWidget {
  const SponsoringPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsoring'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.handshake_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Campagnes de Sponsoring',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Devenez partenaire et sponsorisez des paniers surprises pour les associations et les plus démunis. Cette fonctionnalité sera bientôt disponible.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bientôt disponible')),
                  );
                },
                child: const Text('Devenir Sponsor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
