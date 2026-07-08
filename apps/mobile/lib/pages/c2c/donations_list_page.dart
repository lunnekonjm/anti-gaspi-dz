import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/donations_provider.dart';
import 'create_donation_page.dart';

/// C2C Donations list page — "Onglet Famille".
/// Privacy by design: only neighborhood shown, no exact addresses.
class DonationsListPage extends StatefulWidget {
  const DonationsListPage({super.key});

  @override
  State<DonationsListPage> createState() => _DonationsListPageState();
}

class _DonationsListPageState extends State<DonationsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DonationsProvider>();
      provider.loadDonations();
      provider.loadCommunes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final donations = context.watch<DonationsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabFamily)),
      body: donations.isLoading
          ? const Center(child: CircularProgressIndicator())
          : donations.donations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noOffersAvailable,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => donations.loadDonations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: donations.donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations.donations[index] as Map<String, dynamic>;
                      return _DonationCard(donation: donation);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDonationPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.donateFood),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final Map<String, dynamic> donation;
  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donation['title'] ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              donation['description'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Neighborhood chip — only location info shown
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  donation['neighborhood'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: l10n.shareSuccess),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Privacy notice
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.phoneNumbersHidden,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open messaging
                },
                icon: const Icon(Icons.message_outlined),
                label: Text(l10n.sendMessage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
