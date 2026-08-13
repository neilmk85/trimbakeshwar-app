import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import 'api_service.dart';

class RoomService {
  RoomService._();

  static final rooms = ValueNotifier<List<RoomModel>>([]);
  static final isLoading = ValueNotifier<bool>(false);
  static String? lastError;
  static bool _loaded = false;

  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    isLoading.value = true;
    lastError = null;
    final result = await ApiService.getRooms();
    isLoading.value = false;
    if (result.error == null) {
      rooms.value = result.data.where((r) => r.available).toList();
      _loaded = true;
    } else {
      lastError = result.error;
    }
  }

}
