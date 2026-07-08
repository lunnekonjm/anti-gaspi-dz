import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Donations state management — C2C Onglet Famille.
class DonationsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<dynamic> _donations = [];
  List<String> _communes = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get donations => _donations;
  List<String> get communes => _communes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDonations({String? neighborhood}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _donations = await _api.getDonations(neighborhood: neighborhood);
    } on ApiException catch (e) {
      _error = e.messageFr;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCommunes() async {
    try {
      _communes = await _api.getCommunes();
    } catch (_) {
      _communes = [];
    }
    notifyListeners();
  }

  Future<bool> createDonation(Map<String, dynamic> data) async {
    try {
      final donation = await _api.createDonation(data);
      _donations.insert(0, donation);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.messageFr;
      notifyListeners();
      return false;
    }
  }
}
