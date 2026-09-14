import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/accommodation_model.dart';
import '../models/order_model.dart';
import '../models/pooja_model.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';

String _friendlyError(Object e) {
  // http.ClientException covers web network failures (CORS blocked, fetch failed, etc.)
  if (e is http.ClientException ||
      e is SocketException ||
      e.toString().toLowerCase().contains('socketexception') ||
      e.toString().toLowerCase().contains('connection refused') ||
      e.toString().toLowerCase().contains('failed to fetch') ||
      e.toString().toLowerCase().contains('xmlhttprequest')) {
    return 'Unable to connect to the server.\nPlease check your internet connection and try again.';
  }
  if (e is TimeoutException) {
    return 'Request timed out. Please try again.';
  }
  return 'Something went wrong. Please try again later.';
}

/// Central HTTP client for the Trimbakeshwar Node server.
class ApiService {
  ApiService._();

  static const String _base = 'https://app.trimbakeshwarpoojavidhi.in/api';
  static const String baseUrl = _base;
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
  /// Returns `(otp: '1234', error: null)` on success,
  /// or `(otp: null, error: 'reason')` on failure.
  static Future<({String? otp, String? error})> sendOtp(String phone) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/otp/send'),
            headers: _headers,
            body: jsonEncode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        // OTP is now sent via WhatsApp — not returned in response
        return (otp: 'whatsapp', error: null);
      }
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final msg = body['message'] as String? ?? 'Server error (${res.statusCode})';
        return (otp: null, error: msg);
      } catch (_) {
        return (otp: null, error: 'Server error (${res.statusCode})');
      }
    } catch (e) {
      return (otp: null, error: _friendlyError(e));
    }
  }

  /// Google SSO login — sends verified ID token to server.
  static Future<({UserModel? user, String? error})> ssoGoogleLogin(
      String idToken) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/sso/google'),
            headers: _headers,
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (user: _userFromMap(body['data']), error: null);
      }
      return (user: null, error: body['message'] as String?);
    } catch (e) {
      return (user: null, error: 'Server unreachable. Check your connection.');
    }
  }

  /// Facebook SSO login — sends access token to server.
  static Future<({UserModel? user, String? error})> ssoFacebookLogin(
      String accessToken) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/auth/sso/facebook'),
            headers: _headers,
            body: jsonEncode({'accessToken': accessToken}),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (user: _userFromMap(body['data']), error: null);
      }
      return (user: null, error: body['message'] as String?);
    } catch (e) {
      return (user: null, error: 'Server unreachable. Check your connection.');
    }
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

  /// Fetches user profile by phone. Returns null if not found or on error.
  static Future<UserModel?> getUserProfile(String phone) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/users/$phone'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return _userFromMap(body['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
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

  /// Saves or refreshes the FCM device token for push notifications.
  static Future<void> saveFcmToken(String phone, String token) async {
    try {
      await http
          .patch(
            Uri.parse('$_base/users/$phone/fcm-token'),
            headers: _headers,
            body: jsonEncode({'fcmToken': token}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── Poojas ─────────────────────────────────────────────────────────────────

  static Future<({List<PoojaModel> data, String? error})> getPoojas() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/poojas'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List? ?? [];
        return (
          data: list.map((json) => PoojaModel.fromJson(json)).toList(),
          error: null,
        );
      }
      return (data: <PoojaModel>[], error: 'Server error (${res.statusCode})');
    } catch (e) {
      return (data: <PoojaModel>[], error: _friendlyError(e));
    }
  }

  // ── Rooms ──────────────────────────────────────────────────────────────────

  static Future<({List<RoomModel> data, String? error})> getRooms() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/rooms'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List? ?? [];
        return (
          data: list.map((json) {
            final room = RoomModel.fromJson(json);
            // Convert relative image URLs to absolute URLs
            if (room.imageUrl.isNotEmpty && !room.imageUrl.startsWith('http')) {
              final absoluteUrl = 'https://app.trimbakeshwarpoojavidhi.in/${room.imageUrl}';
              return RoomModel(
                id: room.id,
                name: room.name,
                type: room.type,
                pricePerNight: room.pricePerNight,
                capacity: room.capacity,
                amenities: room.amenities,
                description: room.description,
                imageUrl: absoluteUrl,
                available: room.available,
                displayOrder: room.displayOrder,
                count: room.count,
              );
            }
            return room;
          }).toList(),
          error: null,
        );
      }
      return (data: <RoomModel>[], error: 'Server error (${res.statusCode})');
    } catch (e) {
      return (data: <RoomModel>[], error: _friendlyError(e));
    }
  }

  // ── Accommodation ──────────────────────────────────────────────────────────

  static Future<AccommodationModel> getAccommodation() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/accommodation'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return AccommodationModel.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return AccommodationModel.empty;
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
              'bookingType': order.bookingType,
              if (!order.isRoomOnly) 'poojaName': order.poojaName,
              if (!order.isRoomOnly && order.poojaDate != null)
                'poojaDate': '${order.poojaDate!.year}-${order.poojaDate!.month.toString().padLeft(2, '0')}-${order.poojaDate!.day.toString().padLeft(2, '0')}',
              if (order.checkInDate != null)
                'checkInDate': '${order.checkInDate!.year}-${order.checkInDate!.month.toString().padLeft(2, '0')}-${order.checkInDate!.day.toString().padLeft(2, '0')}',
              'gotra': order.gotra,
              'totalAmount': order.totalAmount,
              'numberOfPeople': order.numberOfPeople,
              'isPrivatePooja': order.isPrivatePooja,
              'poojaRatePerPerson': order.poojaRatePerPerson,
              'numberOfRooms': order.numberOfRooms,
              'numberOfNights': order.numberOfNights,
              'stayRatePerRoom': order.stayRatePerRoom,
              'poojaColorHex': hex,
              'bookedOn': order.bookedOn.toIso8601String(),
              'userPhone': userPhone,
              if (order.selectedRoomId != null)
                'roomId': order.selectedRoomId,
              if (order.selectedRoomName != null)
                'roomName': order.selectedRoomName,
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

  // ── Payments ───────────────────────────────────────────────────────────────

  /// Creates a Razorpay order. Returns data map on success or error string on failure.
  static Future<({Map<String, dynamic>? data, String? error})> createRazorpayOrder(
    int amount,
    String receipt, {
    List<Map<String, dynamic>>? bookings,
  }) async {
    try {
      final payload = <String, dynamic>{'amount': amount, 'receipt': receipt};
      if (bookings != null && bookings.isNotEmpty) payload['bookings'] = bookings;
      final res = await http
          .post(
            Uri.parse('$_base/payments/create-order'),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        return (data: body['data'] as Map<String, dynamic>, error: null);
      }
      return (data: null, error: body['message'] as String? ?? 'Server error (${res.statusCode})');
    } on TimeoutException {
      return (data: null, error: 'Request timed out. Check if the server is running.');
    } catch (e) {
      return (data: null, error: 'Cannot reach server: $e');
    }
  }

  /// Verifies payment and creates bookings on the server.
  static Future<bool> verifyAndCreateBookings({
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
    required List<Map<String, dynamic>> bookings,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/payments/verify'),
            headers: _headers,
            body: jsonEncode({
              'razorpayOrderId': razorpayOrderId,
              'paymentId': paymentId,
              'signature': signature,
              'bookings': bookings,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200 && body['success'] == true;
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

  static Future<({bool available, int availableCount, String message})>
      checkRoomAvailability(String roomId, DateTime checkIn, DateTime checkOut) async {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    try {
      final base = _base.replaceFirst('/api', '');
      final uri = Uri.parse(
          '$base/api/rooms/$roomId/availability?checkIn=${fmt(checkIn)}&checkOut=${fmt(checkOut)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      return (
        available: data['available'] == true,
        availableCount: (data['availableCount'] as num?)?.toInt() ?? 0,
        message: data['message'] as String? ?? '',
      );
    } catch (_) {
      return (available: true, availableCount: 0, message: '');
    }
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
        fullName: (m['fullName'] as String? ?? '').trim() == 'User'
            ? ''
            : (m['fullName'] as String? ?? ''),
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
      bookingType: m['bookingType'] as String? ?? 'pooja',
      poojaDate: DateTime.tryParse(m['poojaDate'] as String? ?? ''),
      checkInDate: DateTime.tryParse(m['checkInDate'] as String? ?? ''),
      gotra: m['gotra'] as String? ?? '',
      numberOfPeople: (m['numberOfPeople'] as num?)?.toInt() ?? 1,
      poojaRatePerPerson: (m['poojaRatePerPerson'] as num?)?.toInt() ?? 0,
      numberOfRooms: (m['numberOfRooms'] as num?)?.toInt() ?? 0,
      numberOfNights: (m['numberOfNights'] as num?)?.toInt() ?? 0,
      stayRatePerRoom: (m['stayRatePerRoom'] as num?)?.toInt() ?? 0,
      totalAmount: (m['totalAmount'] as num?)?.toInt() ?? 0,
      bookedOn:
          DateTime.tryParse(m['bookedOn'] as String? ?? '') ?? DateTime.now(),
      poojaColor: color,
      selectedRoomId: (m['roomId'] as num?)?.toInt(),
      selectedRoomName: m['roomName'] as String?,
      bookedForName: m['bookedForName'] as String?,
      bookedForPhone: m['bookedForPhone'] as String?,
      bookedForEmail: m['bookedForEmail'] as String?,
      bookedForCity: m['bookedForCity'] as String?,
      bookedForZipCode: m['bookedForZipCode'] as String?,
      bookedForCountry: m['bookedForCountry'] as String?,
      cancelled: m['cancelled'] as bool? ?? false,
      rescheduled: m['rescheduled'] as bool? ?? false,
      completed: m['completed'] as bool? ?? false,
      confirmed: m['confirmed'] as bool? ?? false,
      certificateSent: m['certificateSent'] as bool? ?? false,
      isPrivatePooja: m['isPrivatePooja'] as bool? ?? false,
      userName: m['userName'] as String?,
      userPhone: m['userPhone'] as String?,
      razorpayOrderId: m['razorpayOrderId'] as String?,
      paymentId: m['paymentId'] as String?,
      familyNames: (m['familyNames'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
