import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Reservations state management — tracks active bookings and QR codes.
class ReservationsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<dynamic> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReservations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _api.getMyReservations();
    } on ApiException catch (e) {
      _error = e.messageFr;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMerchantReservations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _api.getMerchantReservations();
    } on ApiException catch (e) {
      _error = e.messageFr;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createReservation(String offerId) async {
    try {
      final reservation = await _api.createReservation(offerId);
      return reservation;
    } on ApiException catch (e) {
      _error = e.messageFr;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> initiatePayment(String reservationId) async {
    try {
      return await _api.initiatePayment(reservationId);
    } on ApiException catch (e) {
      _error = e.messageFr;
      notifyListeners();
      return null;
    }
  }
}
