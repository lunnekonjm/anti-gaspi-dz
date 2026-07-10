import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/reservations_provider.dart';
import '../../l10n/app_localizations.dart';

class MerchantDashboardPage extends StatefulWidget {
  const MerchantDashboardPage({Key? key}) : super(key: key);

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationsProvider>().loadMerchantReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reservationsProvider = context.watch<ReservationsProvider>();
    final reservations = reservationsProvider.reservations;

    // Calculate revenue
    double totalRevenue = 0.0;
    int completedReservations = 0;
    for (var res in reservations) {
      if (res['status'] == 'completed') {
        completedReservations++;
        totalRevenue += (res['offer']?['sale_price'] ?? 0).toDouble();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Commerçant'),
      ),
      body: reservationsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => reservationsProvider.loadMerchantReservations(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Revenus',
                          value: '${totalRevenue.toStringAsFixed(2)} DZD',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Ventes',
                          value: completedReservations.toString(),
                          icon: Icons.check_circle_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Historique des Réservations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (reservations.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Aucune réservation trouvée.', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ...reservations.map((res) {
                      final offer = res['offer'] ?? {};
                      final consumer = res['consumer'] ?? {};
                      final status = res['status'] ?? 'pending';
                      final price = offer['sale_price'] ?? 0;
                      
                      Color statusColor;
                      switch (status) {
                        case 'completed': statusColor = Colors.green; break;
                        case 'cancelled': statusColor = Colors.red; break;
                        case 'no_show': statusColor = Colors.orange; break;
                        default: statusColor = Colors.blue;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(offer['title'] ?? 'Offre inconnue', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Client: ${consumer['display_name'] ?? consumer['phone_number'] ?? 'Inconnu'}'),
                              Text('Prix: $price DZD'),
                              if (res['reserved_at'] != null)
                                Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(res['reserved_at']))}'),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
