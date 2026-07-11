import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/donations_provider.dart';
import '../../widgets/dev_badge.dart';
import '../../widgets/info_tooltip.dart';

class CreateDonationPage extends StatefulWidget {
  const CreateDonationPage({super.key});

  @override
  State<CreateDonationPage> createState() => _CreateDonationPageState();
}

class _CreateDonationPageState extends State<CreateDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedNeighborhood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DonationsProvider>();
      if (provider.communes.isEmpty) {
        provider.loadCommunes();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final donations = context.watch<DonationsProvider>();
    final communes = donations.communes;

    return Scaffold(
      appBar: AppBar(title: Text('🤝  ${l10n.donateFood}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Warm intro banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.teal.shade50],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chaque don compte. Décrivez ce que vous partagez, une famille de '
                      'votre quartier pourra le récupérer rapidement.',
                      style: TextStyle(color: Colors.green.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.donationTitle,
                hintText: 'Ex: Légumes frais, pain de la veille...',
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.donationDescription,
                hintText: 'Quantité, état, meilleur créneau pour récupérer...',
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DevBadge(
                    message:
                        "Géolocalisation bloquée par design pour protéger la vie privée des familles. Liste des communes mockée.",
                    child: DropdownButtonFormField<String>(
                      value: _selectedNeighborhood,
                      decoration: InputDecoration(
                        labelText: l10n.selectNeighborhood,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      items: communes
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedNeighborhood = v),
                      validator: (v) => v == null ? 'Champ requis' : null,
                    ),
                  ),
                ),
                InfoTooltip(
                  title: 'Pourquoi seulement le quartier ?',
                  body: 'Pour protéger votre vie privée, votre adresse exacte n\'est jamais '
                      'partagée. Seul le nom du quartier est visible, et les échanges se '
                      'font ensuite via la messagerie intégrée — vos coordonnées restent '
                      'masquées à tout moment.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.phoneNumbersHidden,
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (donations.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(donations.error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: donations.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() && _selectedNeighborhood != null) {
                          final success = await donations.createDonation({
                            'title': _titleController.text,
                            'description': _descController.text,
                            'neighborhood': _selectedNeighborhood,
                          });
                          if (success && mounted) Navigator.pop(context);
                        }
                      },
                icon: donations.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.volunteer_activism),
                label: Text(l10n.publishDonation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
