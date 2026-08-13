import 'dart:convert';
import 'dart:io';

import '../models/order_model.dart';
import '../models/user_model.dart';

/// Persists users and orders to a shared JSON file so the admin app can read it.
class SharedDataService {
  SharedDataService._();

  static const _fileName = 'trimbakeshwar_data.json';

  static String get _filePath {
    // Use /tmp — writable on all platforms without extra entitlements.
    return '/tmp/$_fileName';
  }

  static Future<void> save({
    required List<UserModel> users,
    required List<OrderModel> orders,
  }) async {
    try {
      final data = {
        'lastUpdated': DateTime.now().toIso8601String(),
        'users': users
            .map((u) => {
                  'fullName': u.fullName,
                  'phone': u.phone,
                  'email': u.email,
                  'city': u.city,
                  'pinCode': u.pinCode,
                  'country': u.country,
                })
            .toList(),
        'orders': orders
            .map((o) => {
                  'orderId': o.orderId,
                  'poojaName': o.poojaName,
                  'poojaDate': o.poojaDate,
                  'numberOfRooms': o.numberOfRooms,
                  'numberOfNights': o.numberOfNights,
                  'gotra': o.gotra,
                  'totalAmount': o.totalAmount,
                  'bookedOn': o.bookedOn.toIso8601String(),
                  'poojaColorHex': '#'
                      '${o.poojaColor.r.round().toRadixString(16).padLeft(2, '0')}'
                      '${o.poojaColor.g.round().toRadixString(16).padLeft(2, '0')}'
                      '${o.poojaColor.b.round().toRadixString(16).padLeft(2, '0')}',
                })
            .toList(),
      };
      await File(_filePath).writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
    } catch (_) {
      // Silently fail if file write is not available on this platform.
    }
  }
}
