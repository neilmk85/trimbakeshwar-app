import 'package:flutter/foundation.dart';
import '../models/pooja_model.dart';
import 'api_service.dart';

class PoojaService {
  PoojaService._();

  static final poojas = ValueNotifier<List<PoojaModel>>([]);
  static final isLoading = ValueNotifier<bool>(false);
  static bool _loaded = false;

  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    isLoading.value = true;
    final result = await ApiService.getPoojas();
    if (result.isNotEmpty) {
      poojas.value = result;
      _loaded = true;
    }
    isLoading.value = false;
  }
}
