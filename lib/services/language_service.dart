import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  LanguageService._();

  static final isHindi = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isHindi.value = prefs.getBool('is_hindi') ?? false;
  }

  static Future<void> toggle() async {
    isHindi.value = !isHindi.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_hindi', isHindi.value);
  }
}
