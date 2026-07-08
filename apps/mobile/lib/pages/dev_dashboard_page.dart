import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/dev_provider.dart';

class DevDashboardPage extends StatefulWidget {
  const DevDashboardPage({super.key});

  @override
  State<DevDashboardPage> createState() => _DevDashboardPageState();
}

class _DevDashboardPageState extends State<DevDashboardPage> {
  bool _isLoading = false;

  Future<void> _seedData() async {
    setState(() => _isLoading = true);
    try {
      final dev = context.read<DevProvider>();
      final baseUrl = 'https://anti-gaspi-api.onrender.com/api/v1';
      final response = await http.post(
        Uri.parse('$baseUrl/dev/seed'),
        headers: {'x-api-key': dev.devApiKey},
      );
      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('5 offres de test générées !')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.body}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _wipeData() async {
    setState(() => _isLoading = true);
    try {
      final dev = context.read<DevProvider>();
      final baseUrl = 'https://anti-gaspi-api.onrender.com/api/v1';
      final response = await http.delete(
        Uri.parse('$baseUrl/dev/wipe'),
        headers: {'x-api-key': dev.devApiKey},
      );
      if (mounted) {
        if (response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base de données réinitialisée !')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.body}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin / Dev Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Ce tableau de bord est un outil technique permettant de manipuler la base de données de production/développement pour faciliter les tests du MVP.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_shopping_cart, color: Colors.green),
              title: const Text('Générer 5 fausses offres (Seed)'),
              subtitle: const Text('Injecte 5 annonces B2C dans la base'),
              trailing: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.play_arrow),
              onTap: _isLoading ? null : _seedData,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Vider toutes les données', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Supprime offres, dons et réservations (Garde les comptes)', style: TextStyle(color: Colors.red)),
              trailing: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.delete_sweep, color: Colors.red),
              onTap: _isLoading ? null : _wipeData,
            ),
          ),
        ],
      ),
    );
  }
}
