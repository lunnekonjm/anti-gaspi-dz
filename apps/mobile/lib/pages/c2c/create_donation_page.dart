import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/donations_provider.dart';

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
      appBar: AppBar(title: Text(l10n.donateFood)),
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
            DropdownButtonFormField<String>(
              value: _selectedNeighborhood,
              decoration: InputDecoration(labelText: l10n.selectNeighborhood),
              items: communes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedNeighborhood = v),
              validator: (v) => v == null ? 'Champ requis' : null,
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
              Text(donations.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: donations.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() && _selectedNeighborhood != null) {
                        final success = await donations.createDonation({
                          'title': _titleController.text,
                          'description': _descController.text,
                          'neighborhood': _selectedNeighborhood,
                        });
                        
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
              child: donations.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.publishDonation),
            ),
          ],
        ),
      ),
    );
  }
}
