import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'order_service.dart';

class AuthService {
  AuthService._();

  static final ValueNotifier<UserModel?> userNotifier = ValueNotifier(null);

  static UserModel? get currentUser => userNotifier.value;
  static bool get isLoggedIn => userNotifier.value != null;

  /// Sends OTP via server. Returns the demo OTP string for display, or null.
  static Future<String?> sendOtp(String phone) {
    return ApiService.sendOtp(phone);
  }

  /// Verifies OTP with server. Returns null on success, error message on failure.
  static Future<String?> verifyOtpAndLogin(String phone, String otp) async {
    final result = await ApiService.verifyOtp(phone, otp);
    if (result.user != null) {
      userNotifier.value = result.user;
      await OrderService.loadFromServer(phone);
      return null;
    }
    return result.error ?? 'Incorrect OTP. Please try again.';
  }

  /// Login with password. Returns null on success, error message on failure.
  static Future<String?> loginWithPassword(
      String phone, String password) async {
    final result = await ApiService.loginWithPassword(phone, password);
    if (result.user != null) {
      userNotifier.value = result.user;
      await OrderService.loadFromServer(phone);
      return null;
    }
    return result.error ?? 'Invalid phone or password.';
  }

  /// Registers user. Returns null on success, error message on failure.
  static Future<String?> register(UserModel user) async {
    final result = await ApiService.register(user);
    if (result.user != null) {
      userNotifier.value = result.user;
      return null;
    }
    return result.error ?? 'Registration failed. Please try again.';
  }

  /// Updates the logged-in user profile locally and syncs to server.
  static void updateUser(UserModel updated) {
    userNotifier.value = updated;
    ApiService.updateUser(updated); // fire-and-forget
  }

  static void logout() {
    userNotifier.value = null;
    OrderService.clear();
  }
}
