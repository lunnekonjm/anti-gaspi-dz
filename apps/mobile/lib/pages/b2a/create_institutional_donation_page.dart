import 'package:flutter/material.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';

class CreateInstitutionalDonationPage extends StatefulWidget {
  const CreateInstitutionalDonationPage({super.key});

  @override
  State<CreateInstitutionalDonationPage> createState() => _CreateInstitutionalDonationPageState();
}

class _CreateInstitutionalDonationPageState extends State<CreateInstitutionalDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _volumeController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    _volumeController.dispose();
    super.dispose();
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
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.donationTitle),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: l10n.donationDescription),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quantity),
                    validator: (v) => v == null || v.isEmpty ? '*' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _volumeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Volume (L ou Kg)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        // TODO: Call API for institutional donation
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() => _isLoading = false);
                        if (mounted) Navigator.pop(context);
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.announceSurplus),
            ),
          ],
        ),
      ),
    );
  }
}
