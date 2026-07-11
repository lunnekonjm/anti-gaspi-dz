import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/info_tooltip.dart';
import '../../widgets/success_burst.dart';

class CreateInstitutionalDonationPage extends StatefulWidget {
  const CreateInstitutionalDonationPage({super.key});

  @override
  State<CreateInstitutionalDonationPage> createState() =>
      _CreateInstitutionalDonationPageState();
}

class _CreateInstitutionalDonationPageState extends State<CreateInstitutionalDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _descController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _api.createInstitutionalDonation({
        'description': _descController.text,
        'estimated_quantity': _quantityController.text,
      });
      if (mounted) {
        await showSuccessBurst(context, message: '🌍 Excédent signalé avec succès !');
        if (mounted) Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.messageFr);
    } catch (e) {
      setState(() => _error = 'Erreur de connexion');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('🌍  ${l10n.announceSurplus}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Process explainer — replaces the plain info banner with a
            // step-by-step so the professional knows what happens next.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.teal.shade50]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'Ce qui va se passer',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _MiniStep(emoji: '1️⃣', text: 'Une association proche accepte votre don'),
                  const _MiniStep(emoji: '2️⃣', text: 'Un acte de transfert PDF est généré automatiquement'),
                  const _MiniStep(emoji: '3️⃣', text: 'L\'association signe électroniquement — vous êtes couvert'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description de l\'excédent',
                hintText: 'Ex: 50 baguettes invendues, DLC demain...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      hintText: 'Ex: 50 pièces (~15 kg)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                ),
                const InfoTooltip(
                  title: 'Pourquoi indiquer la quantité ?',
                  body: 'Elle aide l\'association à évaluer si elle peut transporter et '
                      'stocker le don, et permet de calculer votre impact RSE (repas '
                      'sauvés, CO₂ évité) dans votre tableau de bord.',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'L\'acte de transfert vous décharge de toute responsabilité sanitaire '
                      'une fois signé par l\'association.',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.announceSurplus),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStep extends StatelessWidget {
  final String emoji;
  final String text;

  const _MiniStep({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.blue.shade900)),
          ),
        ],
      ),
    );
  }
}
