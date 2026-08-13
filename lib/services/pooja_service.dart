import 'package:flutter/foundation.dart';
import '../constants/app_data.dart';
import '../models/pooja_model.dart';
import 'api_service.dart';

class PoojaService {
  PoojaService._();

  static final poojas = ValueNotifier<List<PoojaModel>>([]);
  static final isLoading = ValueNotifier<bool>(false);
  static final error = ValueNotifier<String?>(null);

  static Future<void> load({bool force = false, bool silent = false}) async {
    if (!force && poojas.value.isNotEmpty) return;
    if (!silent) isLoading.value = true;
    error.value = null;
    final result = await ApiService.getPoojas();
    if (result.data.isNotEmpty) {
      poojas.value = result.data;
    } else {
      // Server unreachable — fall back to bundled AppData
      if (poojas.value.isEmpty) {
        poojas.value = AppData.poojas
            .map((m) => PoojaModel.fromAppData(m))
            .toList();
      }
      if (result.error != null) error.value = result.error;
    }
    if (!silent) isLoading.value = false;
  }
}
