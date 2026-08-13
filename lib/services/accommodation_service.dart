import 'package:flutter/foundation.dart';
import '../models/accommodation_model.dart';
import 'api_service.dart';

class AccommodationService {
  AccommodationService._();

  static final settings = ValueNotifier<AccommodationModel>(AccommodationModel.empty);
  static bool _loaded = false;

  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final result = await ApiService.getAccommodation();
    settings.value = result;
    _loaded = true;
  }
}
