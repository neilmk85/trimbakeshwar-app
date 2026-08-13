import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'notification_service.dart';
import 'order_service.dart';

const _kPhoneKey = 'session_phone';

class AuthService {
  AuthService._();

  static final ValueNotifier<UserModel?> userNotifier = ValueNotifier(null);

  static UserModel? get currentUser => userNotifier.value;
  static bool get isLoggedIn => userNotifier.value != null;

  /// Restores session from local storage on app start.
  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_kPhoneKey);
    if (phone == null || phone.isEmpty) return;
    try {
      final user = await ApiService.getUserProfile(phone);
      if (user != null) {
        userNotifier.value = user;
        await OrderService.loadFromServer(phone);
        NotificationService.uploadToken(phone);
      } else {
        await _clearSession();
      }
    } catch (_) {}
  }

  static Future<void> _saveSession(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhoneKey, phone);
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPhoneKey);
  }

  /// Sends OTP via server. Returns `(otp, null)` on success or `(null, error)` on failure.
  static Future<({String? otp, String? error})> sendOtp(String phone) {
    return ApiService.sendOtp(phone);
  }

  /// Verifies OTP with server. Returns null on success, error message on failure.
  static Future<String?> verifyOtpAndLogin(String phone, String otp) async {
    final result = await ApiService.verifyOtp(phone, otp);
    if (result.user != null) {
      userNotifier.value = result.user;
      await _saveSession(phone);
      await OrderService.loadFromServer(phone);
      NotificationService.uploadToken(phone);
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
      await _saveSession(phone);
      await OrderService.loadFromServer(phone);
      NotificationService.uploadToken(phone);
      return null;
    }
    return result.error ?? 'Invalid phone or password.';
  }

  /// Registers user. Returns null on success, error message on failure.
  static Future<String?> register(UserModel user) async {
    final result = await ApiService.register(user);
    if (result.user != null) {
      userNotifier.value = result.user;
      await _saveSession(result.user!.phone);
      NotificationService.uploadToken(result.user!.phone);
      return null;
    }
    return result.error ?? 'Registration failed. Please try again.';
  }

  /// Updates the logged-in user profile locally and syncs to server.
  static void updateUser(UserModel updated) {
    userNotifier.value = updated;
    ApiService.updateUser(updated); // fire-and-forget
  }

  // ── Replace this with your Web OAuth 2.0 Client ID from Google Cloud Console ──
  static const _googleWebClientId =
      '651026407454-u8bro74v61q7t7j2fid7ve1v1j944qha.apps.googleusercontent.com';

  /// Google SSO login. Returns null on success, error message on failure.
  static Future<String?> signInWithGoogle() async {
    if (_googleWebClientId.startsWith('YOUR_')) {
      return 'Google Sign-In is not configured yet.\n'
          'Set _googleWebClientId in auth_service.dart with your\n'
          'Web OAuth 2.0 Client ID from Google Cloud Console.';
    }
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? _googleWebClientId : null,
        serverClientId: kIsWeb ? null : _googleWebClientId,
      );
      await googleSignIn.signOut(); // clear any cached account
      final account = await googleSignIn.signIn();
      if (account == null) return null; // user cancelled — no error message

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        return 'Could not get Google ID token. '
            'Ensure google-services.json is placed in android/app/.';
      }

      final result = await ApiService.ssoGoogleLogin(idToken);
      if (result.user != null) {
        userNotifier.value = result.user;
        if (result.user!.phone.isNotEmpty) {
          await _saveSession(result.user!.phone);
          await OrderService.loadFromServer(result.user!.phone);
          NotificationService.uploadToken(result.user!.phone);
        }
        return null;
      }
      return result.error ?? 'Google sign-in failed.';
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') return null;
      return 'Google error (${e.code}): ${e.message}';
    } catch (e) {
      return 'Google sign-in failed: $e';
    }
  }


  static Future<String?> signInWithApple() async {
    return 'Apple Sign-In is coming soon.';
  }

  /// Creates a local guest session when the server is unreachable.
  static void loginAsGuest(String phone) {
    userNotifier.value = UserModel(
      fullName: 'Guest',
      phone: phone,
      email: '',
      password: '',
      city: '',
      pinCode: '',
      country: 'India',
    );
  }

  static Future<void> logout() async {
    await _clearSession();
    userNotifier.value = null;
    OrderService.clear();
  }
}
