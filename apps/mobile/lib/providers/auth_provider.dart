import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

/// Auth state management via Provider (ChangeNotifier).
/// Handles login, OTP verification, consent, and session persistence.
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isNewUser = false;
  String _selectedLanguage = 'fr';
  Map<String, dynamic>? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isNewUser => _isNewUser;
  String get selectedLanguage => _selectedLanguage;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;
  String get userRole => _user?['role'] ?? 'consumer';

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await _storage.read(key: 'jwt_token');
    final lang = await _storage.read(key: 'language') ?? 'fr';
    _selectedLanguage = lang;
    if (token != null) {
      try {
        _user = await _api.getProfile();
        _isAuthenticated = true;
        _selectedLanguage = _user?['language_preference'] ?? lang;
      } catch (_) {
        await _storage.delete(key: 'jwt_token');
      }
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _selectedLanguage = lang;
    await _storage.write(key: 'language', value: lang);
    notifyListeners();
  }

  Future<bool> requestOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.requestOtp(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.getMessage(_selectedLanguage);
      } else {
        _errorMessage = _selectedLanguage == 'ar' ? 'خطأ في الاتصال بالخادم (Le serveur démarre peut-être...)' : 'Erreur de connexion (Le serveur démarre peut-être...)';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.verifyOtp(phoneNumber, code);
      final token = data['access_token'];
      _isNewUser = data['is_new_user'] ?? false;
      
      await _storage.write(key: 'jwt_token', value: token);
      await _loadSession();
      return true;
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.getMessage(_selectedLanguage);
      } else {
        _errorMessage = _selectedLanguage == 'ar' ? 'خطأ في الاتصال' : 'Erreur de connexion';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateConsent({
    required bool payment,
    required bool geolocation,
    required bool notifications,
  }) async {
    await _api.updateConsent(
      payment: payment,
      geolocation: geolocation,
      notifications: notifications,
    );
    _user?['consent_payment'] = payment;
    _user?['consent_geolocation'] = geolocation;
    _user?['consent_notifications'] = notifications;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
    await _api.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
