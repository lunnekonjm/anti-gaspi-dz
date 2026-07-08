import 'package:flutter/material.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'create_institutional_donation_page.dart';

/// B2A Institutional Donations page — professional-to-association donations.
class InstitutionalDonationsPage extends StatelessWidget {
  const InstitutionalDonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabInstitutional)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.announceSurplus,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateInstitutionalDonationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.announceSurplus),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to RSE dashboard
                },
                icon: const Icon(Icons.assessment_outlined),
                label: Text(l10n.rseDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
