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
  String? _selectedCommune;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DonationsProvider>();
      provider.loadDonations();
      provider.loadCommunes();
    });
  }

  void _onCommuneChanged(String? commune) {
    setState(() => _selectedCommune = commune);
    context.read<DonationsProvider>().loadDonations(neighborhood: commune);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final donations = context.watch<DonationsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabFamily)),
      body: Column(
        children: [
          // ── Commune filter ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: donations.communes.isEmpty
                      ? const Text('Chargement des quartiers...')
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCommune,
                            hint: const Text('Tous les quartiers'),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tous les quartiers'),
                              ),
                              ...donations.communes.map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                            onChanged: _onCommuneChanged,
                          ),
                        ),
                ),
                if (_selectedCommune != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => _onCommuneChanged(null),
                    tooltip: 'Réinitialiser le filtre',
                  ),
              ],
            ),
          ),
          // ── Donations list ──
          Expanded(
            child: donations.isLoading
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
                              _selectedCommune != null
                                  ? 'Aucun don dans ce quartier'
                                  : l10n.noOffersAvailable,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            if (_selectedCommune != null) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => _onCommuneChanged(null),
                                child: const Text('Voir tous les quartiers'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => donations.loadDonations(
                          neighborhood: _selectedCommune,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donations.donations.length,
                          itemBuilder: (context, index) {
                            final donation = donations.donations[index]
                                as Map<String, dynamic>;
                            return _DonationCard(donation: donation);
                          },
                        ),
                      ),
          ),
        ],
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
    final status = donation['status'] ?? 'available';
    final isReserved = status == 'reserved';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    donation['title'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isReserved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Réservé',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
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
                // Donor name
                if (donation['donor']?['display_name'] != null) ...[
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    donation['donor']['display_name'],
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
                const SizedBox(width: 8),
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
                onPressed: isReserved
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Messagerie en cours de développement (MVP)'),
                          ),
                        );
                      },
                icon: const Icon(Icons.message_outlined),
                label: Text(isReserved ? 'Don déjà réservé' : l10n.sendMessage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
