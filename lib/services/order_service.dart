import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  OrderService._();

  static final ValueNotifier<List<OrderModel>> ordersNotifier =
      ValueNotifier([]);

  static List<OrderModel> get orders => ordersNotifier.value;

  /// Saves order to server first. Returns true on success, false on failure.
  static Future<bool> addOrder(OrderModel order, String userPhone) async {
    final saved = await ApiService.createBooking(order, userPhone);
    if (saved) {
      ordersNotifier.value = [order, ...ordersNotifier.value];
    }
    return saved;
  }

  /// Loads orders from the server for the given user phone.
  static Future<void> loadFromServer(String phone) async {
    final serverOrders = await ApiService.getOrdersByPhone(phone);
    ordersNotifier.value = serverOrders;
  }

  /// Clears local orders on logout.
  static void clear() {
    ordersNotifier.value = [];
  }
}
