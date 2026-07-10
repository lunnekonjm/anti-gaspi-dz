import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/offers_provider.dart';
import '../../l10n/app_localizations.dart';

class OffersMapPage extends StatefulWidget {
  const OffersMapPage({Key? key}) : super(key: key);

  @override
  State<OffersMapPage> createState() => _OffersMapPageState();
}

class _OffersMapPageState extends State<OffersMapPage> {
  GoogleMapController? _mapController;

  // Center on Algiers by default
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(36.7525, 3.04197),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offersProvider = context.watch<OffersProvider>();

    final Set<Marker> markers = offersProvider.offers.map((offer) {
      // In a real app, the merchant would have LatLng coordinates.
      // We simulate positions around Algiers for the mock map.
      // Usually offer.merchant?.lat / lng would be here.
      // Since we don't have lat/lng in the API currently, we'll place them in a circle around Algiers.
      final int index = offersProvider.offers.indexOf(offer);
      final double latOffset = (index % 5) * 0.01;
      final double lngOffset = (index % 3) * 0.01;
      
      return Marker(
        markerId: MarkerId(offer.id),
        position: LatLng(36.7525 + latOffset, 3.04197 + lngOffset),
        infoWindow: InfoWindow(
          title: offer.title,
          snippet: offer.merchantName,
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTooltip ?? 'Map'),
      ),
      body: offersProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
