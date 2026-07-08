import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';
import 'create_offer_page.dart';
import 'reservation_status_page.dart';

/// B2C Offers list page — shows surprise bags with prices and pickup windows.
class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offers = context.watch<OffersProvider>();
    final auth = context.watch<AuthProvider>();
    final isMerchant = auth.userRole == 'merchant';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSurpriseBags),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              // TODO: Navigate to map view
            },
          ),
        ],
      ),
      body: offers.isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noOffersAvailable,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => offers.loadOffers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offers.offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers.offers[index] as Map<String, dynamic>;
                      return _OfferCard(offer: offer);
                    },
                  ),
                ),
      floatingActionButton: isMerchant
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateOfferPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createOffer),
            )
          : null,
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expiryType = offer['expiry_type'] ?? 'DDM';
    final isDLC = expiryType == 'DLC';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with price badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer['merchant']?['display_name'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                // Price badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.salePrice(offer['sale_price']?.toString() ?? '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Original value (strikethrough)
                Text(
                  l10n.originalPrice(offer['initial_value']?.toString() ?? '0'),
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                // DLC/DDM badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDLC ? AppTheme.dlcRed.withValues(alpha: 0.1) : AppTheme.ddmAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber,
                    ),
                  ),
                  child: Text(
                    expiryType,
                    style: TextStyle(
                      color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reserve button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final provider = context.read<ReservationsProvider>();
                final reservation = await provider.createReservation(offer['id']);
                if (reservation != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservationStatusPage(reservation: reservation),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text(l10n.reserveButton),
            ),
          ),
        ],
      ),
    );
  }
}
