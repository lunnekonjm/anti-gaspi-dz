import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'create_institutional_donation_page.dart';

/// B2A Institutional Donations page — professional-to-association donations.
class InstitutionalDonationsPage extends StatefulWidget {
  const InstitutionalDonationsPage({super.key});

  @override
  State<InstitutionalDonationsPage> createState() => _InstitutionalDonationsPageState();
}

class _InstitutionalDonationsPageState extends State<InstitutionalDonationsPage> {
  final ApiService _api = ApiService();
  List<dynamic> _donations = [];
  List<dynamic> _associations = [];
  bool _isLoading = true;
  bool _showRse = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _associations = await _api.getAssociations();
    } catch (_) {
      _associations = [];
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabInstitutional),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showRse = !_showRse),
            icon: Icon(_showRse ? Icons.list : Icons.assessment, color: Colors.white),
            label: Text(
              _showRse ? 'Donations' : 'RSE',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showRse
              ? _buildRseDashboard(context, l10n)
              : _buildMainView(context, l10n),
      floatingActionButton: !_showRse
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateInstitutionalDonationPage(),
                  ),
                );
                if (result == true) _loadData();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.announceSurplus),
            )
          : null,
    );
  }

  Widget _buildMainView(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.business,
                label: 'Associations',
                value: '${_associations.length}',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.volunteer_activism,
                label: 'Excédents',
                value: '${_donations.length}',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Associations list
        if (_associations.isNotEmpty) ...[
          Text(
            'Associations partenaires',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._associations.map((assoc) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.business, color: Colors.blue),
                  ),
                  title: Text(assoc['display_name'] ?? 'Association'),
                  subtitle: Text(assoc['phone_number'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              )),
          const SizedBox(height: 24),
        ],

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.eco, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Comment ça marche ?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StepItem(number: '1', text: 'Signalez votre excédent alimentaire'),
              _StepItem(number: '2', text: 'Une association accepte le don'),
              _StepItem(number: '3', text: 'Acte de transfert de responsabilité généré'),
              _StepItem(number: '4', text: 'Signature électronique par l\'association'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRseDashboard(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // RSE Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(Icons.eco, size: 48, color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Tableau de Bord RSE',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Responsabilité Sociétale des Entreprises',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stats grid
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.restaurant,
                label: 'Repas sauvés',
                value: '127',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.co2,
                label: 'CO₂ évité',
                value: '89 kg',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.handshake,
                label: 'Dons réalisés',
                value: '23',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.savings,
                label: 'Économies',
                value: '45 000 DA',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Monthly breakdown
        Text(
          'Historique des dons',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _RseHistoryItem(month: 'Juillet 2026', meals: 45, co2: '32 kg'),
        _RseHistoryItem(month: 'Juin 2026', meals: 52, co2: '37 kg'),
        _RseHistoryItem(month: 'Mai 2026', meals: 30, co2: '20 kg'),
        const SizedBox(height: 24),

        // Certificate button
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificat RSE en cours de génération... (MVP)')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Télécharger le certificat RSE'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.green.shade600,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _RseHistoryItem extends StatelessWidget {
  final String month;
  final int meals;
  final String co2;

  const _RseHistoryItem({required this.month, required this.meals, required this.co2});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.calendar_month, color: Colors.green.shade700),
        ),
        title: Text(month),
        subtitle: Text('$meals repas sauvés · $co2 CO₂ évité'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
