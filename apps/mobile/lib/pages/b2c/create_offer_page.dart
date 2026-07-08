import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/offers_provider.dart';
import 'package:intl/intl.dart';

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _initialValueController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  DateTime? _pickupStart;
  DateTime? _pickupEnd;
  DateTime? _expiryDate;
  String _expiryType = 'DLC';

  @override
  void dispose() {
    _titleController.dispose();
    _initialValueController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _pickupStart = selected;
      } else {
        _pickupEnd = selected;
      }
    });
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    setState(() {
      _expiryDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offers = context.watch<OffersProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createOffer)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.offerTitle),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _initialValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.initialValue),
                    validator: (v) => v == null || v.isEmpty ? '*' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.saleValue),
                    validator: (v) => v == null || v.isEmpty ? '*' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.quantity),
              validator: (v) => v == null || v.isEmpty ? '*' : null,
            ),
            const SizedBox(height: 24),
            Text(l10n.pickupWindow, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDateTime(context, true),
                    child: Text(_pickupStart == null
                        ? l10n.pickupStart
                        : DateFormat('dd/MM HH:mm').format(_pickupStart!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDateTime(context, false),
                    child: Text(_pickupEnd == null
                        ? l10n.pickupEnd
                        : DateFormat('dd/MM HH:mm').format(_pickupEnd!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _expiryType,
              decoration: InputDecoration(labelText: l10n.expiryType),
              items: [
                DropdownMenuItem(value: 'DLC', child: Text(l10n.expiryTypeDLC)),
                DropdownMenuItem(value: 'DDM', child: Text(l10n.expiryTypeDDM)),
              ],
              onChanged: (v) => setState(() => _expiryType = v!),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _selectExpiryDate(context),
              child: Text(_expiryDate == null
                  ? l10n.expiryDate
                  : DateFormat('dd/MM/yyyy').format(_expiryDate!)),
            ),
            if (offers.error != null) ...[
              const SizedBox(height: 16),
              Text(offers.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: offers.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() &&
                          _pickupStart != null &&
                          _pickupEnd != null &&
                          _expiryDate != null) {
                        
                        final offer = await offers.createOffer({
                          'title': _titleController.text,
                          'initial_value': double.parse(_initialValueController.text),
                          'sale_price': double.parse(_salePriceController.text),
                          'quantity_available': int.parse(_quantityController.text),
                          'pickup_window_start': _pickupStart!.toIso8601String(),
                          'pickup_window_end': _pickupEnd!.toIso8601String(),
                          'expiry_type': _expiryType,
                          'expiry_date': _expiryDate!.toIso8601String(),
                        });
                        
                        if (offer != null && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
              child: offers.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.publishOffer),
            ),
          ],
        ),
      ),
    );
  }
}
