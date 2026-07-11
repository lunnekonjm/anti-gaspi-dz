import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../providers/offers_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_tooltip.dart';
import '../../widgets/success_burst.dart';

/// Create offer as a guided 3-step flow instead of one long form:
/// 1) What are you selling  2) When can it be picked up  3) Review & publish.
/// Each step validates before allowing "Next", and step 3 shows a live
/// preview of the offer card exactly as buyers will see it.
class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _step1Key = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _initialValueController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  DateTime? _pickupStart;
  DateTime? _pickupEnd;
  DateTime? _expiryDate;
  String _expiryType = 'DLC';

  int _currentStep = 0;
  
  XFile? _imageFile;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _initialValueController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  bool get _step2Valid => _pickupStart != null && _pickupEnd != null && _expiryDate != null;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _uploadedImageUrl = null; // reset if new image picked
      });
    }
  }

  Future<bool> _uploadImageToServer() async {
    if (_imageFile == null) return true;

    try {
      final bytes = await _imageFile!.readAsBytes();
      final uri = Uri.parse('http://localhost:3000/api/v1/uploads/image'); // Ideally from Config
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: _imageFile!.name));

      final token = context.read<AuthProvider>().token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonMap = json.decode(responseBody);
        _uploadedImageUrl = jsonMap['url'];
        return true;
      } else {
        debugPrint('Upload Error: $responseBody');
      }
    } catch (e) {
      debugPrint('Upload Exception: $e');
    }
    return false;
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
    setState(() => _expiryDate = date);
  }

  void _next() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_step2Valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci de compléter les dates avant de continuer')),
        );
        return;
      }
    }
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _publish(OffersProvider offers) async {
    setState(() => _isUploading = true);
    
    if (_imageFile != null && _uploadedImageUrl == null) {
      final success = await _uploadImageToServer();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger l\'image. L\'offre sera publiée sans image.')),
        );
      }
    }
    
    final Map<String, dynamic> payload = {
      'title': _titleController.text,
      'initial_value': double.parse(_initialValueController.text),
      'sale_price': double.parse(_salePriceController.text),
      'quantity_available': int.parse(_quantityController.text),
      'pickup_window_start': _pickupStart!.toIso8601String(),
      'pickup_window_end': _pickupEnd!.toIso8601String(),
      'expiry_type': _expiryType,
      'expiry_date': _expiryDate!.toIso8601String(),
    };
    
    if (_uploadedImageUrl != null) {
      payload['photo_url'] = _uploadedImageUrl;
    }

    final offer = await offers.createOffer(payload);
    
    setState(() => _isUploading = false);
    
    if (offer != null && mounted) {
      await showSuccessBurst(context, message: '🎉 Offre publiée !');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offers = context.watch<OffersProvider>();
    final isLoading = offers.isLoading || _isUploading;

    return Scaffold(
      appBar: AppBar(title: Text('🛍️  ${l10n.createOffer}')),
      body: Column(
        children: [
          _StepProgress(currentStep: _currentStep),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppTheme.normalAnim,
              child: switch (_currentStep) {
                0 => _StepWhat(
                    key: const ValueKey('step0'),
                    formKey: _step1Key,
                    titleController: _titleController,
                    initialValueController: _initialValueController,
                    salePriceController: _salePriceController,
                    quantityController: _quantityController,
                    imageFile: _imageFile,
                    onPickImage: _pickImage,
                    l10n: l10n,
                  ),
                1 => _StepWhen(
                    key: const ValueKey('step1'),
                    pickupStart: _pickupStart,
                    pickupEnd: _pickupEnd,
                    expiryDate: _expiryDate,
                    expiryType: _expiryType,
                    onPickStart: () => _selectDateTime(context, true),
                    onPickEnd: () => _selectDateTime(context, false),
                    onPickExpiry: () => _selectExpiryDate(context),
                    onExpiryTypeChanged: (v) => setState(() => _expiryType = v),
                    l10n: l10n,
                  ),
                _ => _StepReview(
                    key: const ValueKey('step2'),
                    title: _titleController.text,
                    initialValue: _initialValueController.text,
                    salePrice: _salePriceController.text,
                    quantity: _quantityController.text,
                    pickupStart: _pickupStart!,
                    pickupEnd: _pickupEnd!,
                    expiryDate: _expiryDate!,
                    expiryType: _expiryType,
                    imageFile: _imageFile,
                    error: offers.error?.messageFr,
                    l10n: l10n,
                  ),
              },
            ),
          ),
          _StepNavBar(
            currentStep: _currentStep,
            isLoading: isLoading,
            onBack: _currentStep > 0 ? _back : null,
            onNext: _currentStep < 2 ? _next : () => _publish(offers),
            nextLabel: _currentStep < 2 ? 'Continuer' : l10n.publishOffer,
          ),
        ],
      ),
    );
  }
}

// ── Step progress indicator ──
class _StepProgress extends StatelessWidget {
  final int currentStep;
  const _StepProgress({required this.currentStep});

  static const _labels = ['Quoi', 'Quand', 'Vérifier'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= currentStep;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: active ? AppTheme.primaryGreen : Colors.grey.shade300,
                  child: i < currentStep
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                              color: active ? Colors.white : Colors.grey.shade600, fontSize: 12)),
                ),
                const SizedBox(width: 6),
                Text(_labels[i],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        color: active ? AppTheme.primaryGreen : Colors.grey.shade500)),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: i < currentStep ? AppTheme.primaryGreen : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: What ──
class _StepWhat extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController initialValueController;
  final TextEditingController salePriceController;
  final TextEditingController quantityController;
  final XFile? imageFile;
  final VoidCallback onPickImage;
  final AppLocalizations l10n;

  const _StepWhat({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.initialValueController,
    required this.salePriceController,
    required this.quantityController,
    required this.imageFile,
    required this.onPickImage,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Que proposez-vous ? 🛍️',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Décrivez le panier et son prix', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          
          // Image Picker
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                        ? Image.network(imageFile!.path, fit: BoxFit.cover, width: double.infinity)
                        : Image.network(imageFile!.path, fit: BoxFit.cover, width: double.infinity), // using network for XFile in web
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500, size: 32),
                        const SizedBox(height: 8),
                        Text('Ajouter une photo (optionnel)', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: l10n.offerTitle,
              hintText: 'Ex: Panier boulangerie surprise',
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: initialValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: l10n.initialValue, prefixIcon: const Icon(Icons.sell_outlined)),
                  validator: (v) => v == null || v.isEmpty ? '*' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: salePriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: l10n.saleValue, prefixIcon: const Icon(Icons.local_offer_outlined)),
                  validator: (v) => v == null || v.isEmpty ? '*' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: l10n.quantity, prefixIcon: const Icon(Icons.inventory_2_outlined)),
            validator: (v) => v == null || v.isEmpty ? '*' : null,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: When ──
class _StepWhen extends StatelessWidget {
  final DateTime? pickupStart;
  final DateTime? pickupEnd;
  final DateTime? expiryDate;
  final String expiryType;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onPickExpiry;
  final ValueChanged<String> onExpiryTypeChanged;
  final AppLocalizations l10n;

  const _StepWhen({
    super.key,
    required this.pickupStart,
    required this.pickupEnd,
    required this.expiryDate,
    required this.expiryType,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPickExpiry,
    required this.onExpiryTypeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Quand récupérer ? ⏰',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Créneau de retrait et date de péremption', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        const Text('Créneau de retrait', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPickStart,
                child: Text(pickupStart == null
                    ? l10n.pickupStart
                    : DateFormat('dd/MM HH:mm').format(pickupStart!)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: onPickEnd,
                child: Text(
                    pickupEnd == null ? l10n.pickupEnd : DateFormat('dd/MM HH:mm').format(pickupEnd!)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: expiryType,
                decoration: InputDecoration(labelText: l10n.expiryType),
                items: [
                  DropdownMenuItem(value: 'DLC', child: Text('⏰ ${l10n.expiryTypeDLC}')),
                  DropdownMenuItem(value: 'DDM', child: Text('📅 ${l10n.expiryTypeDDM}')),
                ],
                onChanged: (v) => onExpiryTypeChanged(v!),
              ),
            ),
            InfoTooltip(
              title: 'DLC vs DDM — laquelle choisir ?',
              body: 'Choisissez DLC si le produit est périssable et ne doit pas être '
                  'consommé après la date (ex : produits frais, laitages).\n\n'
                  'Choisissez DDM si le produit reste consommable au-delà avec une '
                  'qualité qui peut légèrement baisser (ex : pain, pâtisseries sèches).',
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onPickExpiry,
          icon: const Icon(Icons.event_outlined),
          label:
              Text(expiryDate == null ? l10n.expiryDate : DateFormat('dd/MM/yyyy').format(expiryDate!)),
        ),
      ],
    );
  }
}

// ── Step 3: Review with live preview ──
class _StepReview extends StatelessWidget {
  final String title;
  final String initialValue;
  final String salePrice;
  final String quantity;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final DateTime expiryDate;
  final String expiryType;
  final XFile? imageFile;
  final String? error;
  final AppLocalizations l10n;

  const _StepReview({
    super.key,
    required this.title,
    required this.initialValue,
    required this.salePrice,
    required this.quantity,
    required this.pickupStart,
    required this.pickupEnd,
    required this.expiryDate,
    required this.expiryType,
    required this.imageFile,
    required this.error,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDLC = expiryType == 'DLC';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Aperçu avant publication 👀',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Voici comment votre offre apparaîtra aux acheteurs',
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),

        // Live preview card — mirrors the real offer card style
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageFile != null)
                Image.network(imageFile!.path, height: 140, fit: BoxFit.cover, width: double.infinity),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen.withValues(alpha: 0.1), Colors.transparent]),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title.isEmpty ? '(Titre)' : title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(20)),
                      child: Text('$salePrice DA',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Valeur initiale : $initialValue DA',
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough, color: Colors.grey.shade500)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber),
                          ),
                          child: Text(expiryType,
                              style: TextStyle(
                                  color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('📦 Quantité : $quantity',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    Text(
                        '⏰ Retrait : ${DateFormat('dd/MM HH:mm').format(pickupStart)} → ${DateFormat('HH:mm').format(pickupEnd)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    Text('📅 Péremption : ${DateFormat('dd/MM/yyyy').format(expiryDate)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(error!, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ],
    );
  }
}

// ── Bottom navigation bar (Back / Next / Publish) ──
class _StepNavBar extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepNavBar({
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (onBack != null)
            Expanded(
              child: OutlinedButton(onPressed: isLoading ? null : onBack, child: const Text('Retour')),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(currentStep < 2 ? Icons.arrow_forward : Icons.send),
              label: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}
