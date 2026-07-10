import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_tooltip.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/success_burst.dart';
import 'create_offer_page.dart';
import 'reservation_status_page.dart';

/// B2C Offers list page — shows surprise bags with prices and pickup windows.
class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  bool _showBanner = true;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(child: Text('🛍️  ')),
            Text(l10n.tabSurpriseBags),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.mapTooltip,
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              // TODO: Navigate to map view
            },
          ),
        ],
      ),
      body: offers.isLoading
          ? const ShimmerCardList()
          : offers.error != null
              ? _ErrorState(
                  message: offers.error!.getMessage(auth.selectedLanguage),
                  onRetry: () => offers.loadOffers(),
                  l10n: l10n,
                )
              : offers.offers.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : RefreshIndicator(
                  onRefresh: () => offers.loadOffers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offers.offers.length + (_showBanner ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_showBanner && index == 0) {
                        return ExplainerBanner(
                          emoji: '💡',
                          title: AppLocalizations.of(context)!.howItWorksTitle,
                          body: AppLocalizations.of(context)!.howItWorksBody,
                          onDismiss: () => setState(() => _showBanner = false),
                        );
                      }
                      final offerIndex = index - (_showBanner ? 1 : 0);
                      final offer = offers.offers[offerIndex] as Map<String, dynamic>;
                      return FadeSlideIn(
                        index: offerIndex,
                        child: _OfferCard(offer: offer),
                      );
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

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(child: Text('🛍️', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          Text(
            l10n.noOffersAvailable,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.comeBackLater,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(child: Text('⚠️', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
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
          if (offer['photo_url'] != null && offer['photo_url'].isNotEmpty)
            CachedNetworkImage(
              imageUrl: offer['photo_url'],
              height: 150,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox(
                height: 150,
                child: Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
              ),
              placeholder: (context, url) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          // Header with price badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                  Colors.transparent,
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
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            offer['merchant']?['display_name'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
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
                // DLC/DDM badge with explanation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDLC
                        ? AppTheme.dlcRed.withValues(alpha: 0.1)
                        : AppTheme.ddmAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(child: Text(isDLC ? '⏰' : '📅', style: const TextStyle(fontSize: 12))),
                      const SizedBox(width: 4),
                      Text(
                        expiryType,
                        style: TextStyle(
                          color: isDLC ? AppTheme.dlcRed : AppTheme.ddmAmber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                InfoTooltip(
                  title: l10n.dlcVsDdmTitle,
                  body: l10n.dlcVsDdmBody,
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
                  await showSuccessBurst(context, message: '🎉 Réservation confirmée !');
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationStatusPage(reservation: reservation),
                      ),
                    );
                  }
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