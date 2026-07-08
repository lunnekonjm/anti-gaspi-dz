import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Offers state management — B2C Sacs Surprise.
class OffersProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<dynamic> _offers = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOffers({double? lat, double? lng, double? radius}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offers = await _api.getOffers(lat: lat, lng: lng, radius: radius);
    } on ApiException catch (e) {
      _error = e.messageFr;
    } catch (e) {
      _error = 'Erreur de connexion';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createOffer(Map<String, dynamic> data) async {
    try {
      final offer = await _api.createOffer(data);
      _offers.insert(0, offer);
      notifyListeners();
      return offer;
    } on ApiException catch (e) {
      _error = e.messageFr;
      notifyListeners();
      return null;
    }
  }
}
