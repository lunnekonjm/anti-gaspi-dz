import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class CreateInstitutionalDonationPage extends StatefulWidget {
  const CreateInstitutionalDonationPage({super.key});

  @override
  State<CreateInstitutionalDonationPage> createState() => _CreateInstitutionalDonationPageState();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excédent signalé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
      appBar: AppBar(title: Text(l10n.announceSurplus)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Signalez votre surplus alimentaire. Une association pourra le récupérer avec un acte de transfert de responsabilité sanitaire.',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                    ),
                  ),
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
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: l10n.quantity,
                hintText: 'Ex: 50 pièces (~15 kg)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.scale),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
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
