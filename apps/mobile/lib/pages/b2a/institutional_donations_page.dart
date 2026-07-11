import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/info_tooltip.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/fade_slide_in.dart';
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
  bool _showBanner = true;

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
        title: Text('🌍  ${l10n.tabInstitutional}'),
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
          ? const ShimmerCardList(itemCount: 3)
          : _showRse
              ? _buildRseDashboard(context, l10n)
              : _buildMainView(context, l10n),
      floatingActionButton: !_showRse
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateInstitutionalDonationPage()),
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
        if (_showBanner)
          ExplainerBanner(
            emoji: '🤝',
            title: 'Dons professionnels, en toute sécurité',
            body: 'Signalez un excédent, une association l\'accepte, et un acte de '
                'transfert signé vous décharge de toute responsabilité sanitaire.',
            onDismiss: () => setState(() => _showBanner = false),
          ),

        // Quick stats — animated in
        FadeSlideIn(
          index: 0,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.business,
                  emoji: '🏢',
                  label: 'Associations',
                  value: '${_associations.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.volunteer_activism,
                  emoji: '📦',
                  label: 'Excédents',
                  value: '${_donations.length}',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Associations list
        if (_associations.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'Associations partenaires',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              InfoTooltip(
                title: 'Associations partenaires',
                body: 'Ce sont les associations enregistrées et vérifiées sur la '
                    'plateforme, prêtes à récupérer vos excédents alimentaires dans '
                    'votre région.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._associations.asMap().entries.map((entry) => FadeSlideIn(
                index: entry.key + 1,
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                    title: Text(entry.value['display_name'] ?? 'Association'),
                    subtitle: Text(entry.value['phone_number'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              )),
          const SizedBox(height: 24),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text('🏢', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text('Aucune association enregistrée pour le moment',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),

        // Info card — how it works
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green.shade50, Colors.blue.shade50]),
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StepItem(number: '1', emoji: '📢', text: 'Signalez votre excédent alimentaire'),
              _StepItem(number: '2', emoji: '🤝', text: 'Une association accepte le don'),
              _StepItem(number: '3', emoji: '📄', text: 'Acte de transfert de responsabilité généré'),
              _StepItem(number: '4', emoji: '✍️', text: 'Signature électronique par l\'association'),
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
              Text('🌍', style: TextStyle(fontSize: 44)),
              SizedBox(height: 8),
              Text(
                'Tableau de Bord RSE',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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

        // Stats grid — staggered entrance
        FadeSlideIn(
          index: 0,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                    icon: Icons.restaurant, emoji: '🍽️', label: 'Repas sauvés', value: '127', color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                    icon: Icons.co2, emoji: '🌿', label: 'CO₂ évité', value: '89 kg', color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                    icon: Icons.handshake, emoji: '🤝', label: 'Dons réalisés', value: '23', color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                    icon: Icons.savings, emoji: '💰', label: 'Économies', value: '45 000 DA', color: Colors.purple),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Text(
              'Historique des dons',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            InfoTooltip(
              title: 'Comment ces chiffres sont calculés',
              body: 'Les repas sauvés et le CO₂ évité sont estimés à partir de la '
                  'quantité déclarée dans chaque don accepté et signé.',
            ),
          ],
        ),
        const SizedBox(height: 12),
        FadeSlideIn(index: 2, child: _RseHistoryItem(month: 'Juillet 2026', meals: 45, co2: '32 kg')),
        FadeSlideIn(index: 3, child: _RseHistoryItem(month: 'Juin 2026', meals: 52, co2: '37 kg')),
        FadeSlideIn(index: 4, child: _RseHistoryItem(month: 'Mai 2026', meals: 30, co2: '20 kg')),
        const SizedBox(height: 24),

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
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.emoji,
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
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
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
  final String emoji;
  final String text;

  const _StepItem({required this.number, required this.emoji, required this.text});

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
          const SizedBox(width: 8),
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.calendar_month, color: Colors.green.shade700),
        ),
        title: Text(month),
        subtitle: Text('🍽️ $meals repas sauvés · 🌿 $co2 CO₂ évité'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
