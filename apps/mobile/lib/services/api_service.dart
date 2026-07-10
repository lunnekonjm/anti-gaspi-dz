import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized API service for all backend communication.
/// Handles JWT auth, bilingual errors, and base URL configuration.
/// Closes A1-08: Use --dart-define=API_URL=... instead of bundled .env
class ApiService {
  // Read from --dart-define at build time, with dev fallback
  static const String _defaultUrl = 'https://anti-gaspi-api.onrender.com/api/v1';
  String get _baseUrl => const String.fromEnvironment('API_URL', defaultValue: _defaultUrl);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> get _token => _storage.read(key: 'jwt_token');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _token;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- Auth ---
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    return _post('/auth/otp/request', {'phone_number': phoneNumber}, auth: false);
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String code) async {
    final response = await _post('/auth/otp/verify', {
      'phone_number': phoneNumber,
      'code': code,
    }, auth: false);
    if (response['access_token'] != null) {
      await _storage.write(key: 'jwt_token', value: response['access_token']);
    }
    return response;
  }

  Future<void> updateConsent({
    required bool payment,
    required bool geolocation,
    required bool notifications,
  }) async {
    await _post('/users/consent', {
      'consent_payment': payment,
      'consent_geolocation': geolocation,
      'consent_notifications': notifications,
    });
  }

  Future<Map<String, dynamic>> getProfile() async => _get('/users/me');

  Future<void> deleteAccount() async => _delete('/users/me');

  // --- Offers (B2C) ---
  Future<List<dynamic>> getOffers({double? lat, double? lng, double? radius}) async {
    final params = <String, String>{};
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (radius != null) params['radius'] = radius.toString();
    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    return _getList('/offers$query');
  }

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> data) async {
    return _post('/offers', data);
  }

  // --- Reservations ---
  Future<Map<String, dynamic>> createReservation(String offerId) async {
    return _post('/reservations', {'offer_id': offerId});
  }

  Future<Map<String, dynamic>> initiatePayment(String reservationId) async {
    return _post('/payments/initiate', {'reservation_id': reservationId});
  }

  Future<Map<String, dynamic>> redeemReservation(String id, String qrToken) async {
    return _post('/reservations/$id/redeem', {'qr_code_token': qrToken});
  }

  Future<List<dynamic>> getMyReservations() async => _getList('/reservations/mine');

  // --- Donations (C2C) ---
  Future<List<dynamic>> getDonations({String? neighborhood}) async {
    final query = neighborhood != null ? '?neighborhood=$neighborhood' : '';
    return _getList('/donations$query');
  }

  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> data) async {
    return _post('/donations', data);
  }

  Future<Map<String, dynamic>> sendDonationMessage(String donationId, String content) async {
    return _post('/donations/$donationId/messages', {'content': content});
  }

  Future<List<dynamic>> getDonationMessages(String donationId) async {
    return _getList('/donations/$donationId/messages');
  }

  Future<List<String>> getCommunes() async {
    final response = await _get('/donations/communes');
    return (response as List).cast<String>();
  }

  // --- Institutional Donations (B2A) ---
  Future<Map<String, dynamic>> createInstitutionalDonation(Map<String, dynamic> data) async {
    return _post('/institutional-donations', data);
  }

  Future<Map<String, dynamic>> acceptInstitutionalDonation(String id) async {
    return _post('/institutional-donations/$id/accept', {});
  }

  Future<Map<String, dynamic>> generateTransferDeed(String id) async {
    return _post('/institutional-donations/$id/transfer', {});
  }

  Future<Map<String, dynamic>> signTransferDeed(String id) async {
    return _post('/institutional-donations/$id/sign', {});
  }

  Future<List<dynamic>> getAssociations() async {
    return _getList('/institutional-donations/associations');
  }

  // --- FCM Token ---
  Future<void> updateFcmToken(String token) async {
    await _put('/users/me/fcm-token', {'fcm_token': token});
  }

  // --- Logout ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // --- HTTP helpers ---
  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } on SocketException {
      throw _offlineError();
    } on TimeoutException {
      throw _timeoutError();
    }
  }

  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as List<dynamic>;
      }
      throw _parseError(response);
    } on SocketException {
      throw _offlineError();
    } on TimeoutException {
      throw _timeoutError();
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(auth: auth),
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } on SocketException {
      throw _offlineError();
    } on TimeoutException {
      throw _timeoutError();
    }
  }

  Future<void> _delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode >= 300) {
        throw _parseError(response);
      }
    } on SocketException {
      throw _offlineError();
    } on TimeoutException {
      throw _timeoutError();
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw _parseError(response);
  }

  ApiException _parseError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return ApiException(
        statusCode: response.statusCode,
        messageFr: body['message_fr'] ?? 'Erreur inconnue',
        messageAr: body['message_ar'] ?? 'خطأ غير معروف',
      );
    } catch (_) {
      return ApiException(
        statusCode: response.statusCode,
        messageFr: 'Erreur serveur',
        messageAr: 'خطأ في الخادم',
      );
    }
  }

  ApiException _offlineError() {
    return ApiException(
      statusCode: 0,
      messageFr: 'Aucune connexion Internet',
      messageAr: 'لا يوجد اتصال بالإنترنت',
    );
  }

  ApiException _timeoutError() {
    return ApiException(
      statusCode: 408,
      messageFr: 'Le serveur met trop de temps à répondre (il démarre peut-être).',
      messageAr: 'يستغرق الخادم وقتًا طويلاً للرد (قد يكون قيد بدء التشغيل).',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String messageFr;
  final String messageAr;

  ApiException({
    required this.statusCode,
    required this.messageFr,
    required this.messageAr,
  });

  String getMessage(String locale) => locale == 'ar' ? messageAr : messageFr;

  @override
  String toString() => 'ApiException($statusCode): $messageFr / $messageAr';
}
