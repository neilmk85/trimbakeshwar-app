import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/pooja_model.dart';
import '../models/user_model.dart';

/// Central HTTP client for the Trimbakeshwar Spring Boot server.
/// Base URL: http://localhost:8080/api
class ApiService {
  ApiService._();

  static const String _base = 'http://localhost:8080/api';
  static final _headers = {'Content-Type': 'application/json'};

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Registers a new user. Returns the created [UserModel] or null on failure.
  static Future<({UserModel? user, String? error})> register(
      UserModel user) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/register'),
            headers: _headers,
            body: jsonEncode(_userToMap(user)),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (user: _userFromMap(body['data']), error: null);
      }
      return (user: null, error: body['message'] as String?);
    } catch (e) {
      return (user: null, error: 'Server unreachable. Check your connection.');
    }
  }

  /// Login with phone + password. Returns [UserModel] or null.
  static Future<({UserModel? user, String? error})> loginWithPassword(
      String phone, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/login'),
            headers: _headers,
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (user: _userFromMap(body['data']), error: null);
      }
      return (user: null, error: body['message'] as String?);
    } catch (e) {
      return (user: null, error: 'Server unreachable. Check your connection.');
    }
  }

  /// Sends OTP to the phone. Returns the demo OTP string or null on failure.
  static Future<String?> sendOtp(String phone) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/otp/send'),
            headers: _headers,
            body: jsonEncode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return (body['data'] as Map<String, dynamic>?)?['otp'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Verifies OTP and returns [UserModel] on success.
  static Future<({UserModel? user, String? error})> verifyOtp(
      String phone, String otp) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/otp/verify'),
            headers: _headers,
            body: jsonEncode({'phone': phone, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (user: _userFromMap(body['data']), error: null);
      }
      return (user: null, error: body['message'] as String?);
    } catch (e) {
      return (user: null, error: 'Server unreachable. Check your connection.');
    }
  }

  /// Updates user profile on the server (fire-and-forget safe).
  static Future<void> updateUser(UserModel user) async {
    try {
      await http
          .put(
            Uri.parse('$_base/users/${user.phone}'),
            headers: _headers,
            body: jsonEncode(_userToMap(user)),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── Poojas ─────────────────────────────────────────────────────────────────

  static Future<List<PoojaModel>> getPoojas() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/poojas'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List? ?? [];
        return list.map((json) => PoojaModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Orders ─────────────────────────────────────────────────────────────────

  /// Saves a booking to the server. Returns true on success.
  static Future<bool> createBooking(OrderModel order, String userPhone) async {
    try {
      final hex = '#'
          '${order.poojaColor.r.round().toRadixString(16).padLeft(2, '0')}'
          '${order.poojaColor.g.round().toRadixString(16).padLeft(2, '0')}'
          '${order.poojaColor.b.round().toRadixString(16).padLeft(2, '0')}';
      final res = await http
          .post(
            Uri.parse('$_base/bookings'),
            headers: _headers,
            body: jsonEncode({
              'orderId': order.orderId,
              'poojaName': order.poojaName,
              'poojaDate': '${order.poojaDate.year}-${order.poojaDate.month.toString().padLeft(2, '0')}-${order.poojaDate.day.toString().padLeft(2, '0')}',
              'numberOfPeople': order.numberOfPeople,
              'gotra': order.gotra,
              'totalAmount': order.totalAmount,
              'poojaColorHex': hex,
              'bookedOn': order.bookedOn.toIso8601String(),
              'userPhone': userPhone,
              if (order.bookedForName != null)
                'bookedForName': order.bookedForName,
              if (order.bookedForPhone != null)
                'bookedForPhone': order.bookedForPhone,
              if (order.bookedForEmail != null)
                'bookedForEmail': order.bookedForEmail,
              if (order.bookedForCity != null)
                'bookedForCity': order.bookedForCity,
              if (order.bookedForZipCode != null)
                'bookedForZipCode': order.bookedForZipCode,
              if (order.bookedForCountry != null)
                'bookedForCountry': order.bookedForCountry,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetches all orders for a user from the server.
  static Future<List<OrderModel>> getOrdersByPhone(String phone) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/bookings/user/$phone'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List? ?? [];
        return list.map((json) => _orderFromMap(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── JSON helpers ───────────────────────────────────────────────────────────

  static Map<String, dynamic> _userToMap(UserModel u) => {
        'fullName': u.fullName,
        'phone': u.phone,
        'email': u.email,
        'password': u.password,
        'city': u.city,
        'pinCode': u.pinCode,
        'country': u.country,
      };

  static UserModel _userFromMap(Map<String, dynamic> m) => UserModel(
        fullName: m['fullName'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String? ?? '',
        password: m['password'] as String? ?? '',
        city: m['city'] as String? ?? '',
        pinCode: m['pinCode'] as String? ?? '',
        country: m['country'] as String? ?? 'India',
      );

  static OrderModel _orderFromMap(Map<String, dynamic> m) {
    final hex = (m['poojaColorHex'] as String? ?? '#1565C0')
        .replaceFirst('#', '');
    final color = Color(int.parse('FF$hex', radix: 16));
    return OrderModel(
      orderId: m['orderId'] as String? ?? '',
      poojaName: m['poojaName'] as String? ?? '',
      poojaDate: DateTime.tryParse(m['poojaDate'] as String? ?? '') ?? DateTime.now(),
      numberOfPeople: (m['numberOfPeople'] as num?)?.toInt() ?? 1,
      gotra: m['gotra'] as String? ?? '',
      totalAmount: (m['totalAmount'] as num?)?.toInt() ?? 0,
      bookedOn:
          DateTime.tryParse(m['bookedOn'] as String? ?? '') ?? DateTime.now(),
      poojaColor: color,
      bookedForName: m['bookedForName'] as String?,
      bookedForPhone: m['bookedForPhone'] as String?,
      bookedForEmail: m['bookedForEmail'] as String?,
      bookedForCity: m['bookedForCity'] as String?,
      bookedForZipCode: m['bookedForZipCode'] as String?,
      bookedForCountry: m['bookedForCountry'] as String?,
      cancelled: m['cancelled'] as bool? ?? false,
    );
  }
}
