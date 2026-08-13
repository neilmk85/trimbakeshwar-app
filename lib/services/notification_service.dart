import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/orders_screen.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage _) async {
  // System handles display; no action needed
}

class NotificationService {
  NotificationService._();

  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  /// Global navigator key — pass to MaterialApp so we can navigate from anywhere.
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const _channelId = 'trimbakeshwar_v3';
  static const _channelName = 'Trimbakeshwar Notifications';
  static const _channelDesc = 'Booking confirmations and temple updates';

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Create Android high-importance channel
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ));
    }

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      // Foreground local notification tapped
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    // Show banner + sound even when app is in foreground on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Show local notification for foreground messages on Android
    FirebaseMessaging.onMessage.listen(_showLocal);

    // App in background → user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleData(msg.data);
    });

    // App terminated → user taps notification that launched the app
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Delay until the widget tree is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleData(initial.data);
      });
    }

    // Subscribe to app_updates topic for broadcast update notifications
    try {
      await _fcm.subscribeToTopic('app_updates');
      debugPrint('[FCM] Subscribed to app_updates topic');
    } catch (e) {
      debugPrint('[FCM] Failed to subscribe to app_updates: $e');
    }

    // Print token for debugging
    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
  }

  /// Navigate or show dialog based on notification data.
  static void _handleData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'app_update') {
      _showAppUpdateDialog(
        version: data['version'] as String? ?? '',
        downloadUrl: data['downloadUrl'] as String? ?? '',
      );
      return;
    }
    final orderId = data['orderId'] as String?;
    if (type == 'booking_confirmed' || type == 'booking_rescheduled' || type == 'booking_reminder') {
      _openOrders(orderId);
    }
  }

  static void _showAppUpdateDialog({required String version, required String downloadUrl}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    final context = nav.overlay?.context;
    if (context == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AppUpdateDialog(version: version, downloadUrl: downloadUrl),
    );
  }

  static void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handleData(data);
    } catch (_) {}
  }

  static void _openOrders(String? orderId) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.push(MaterialPageRoute(
      builder: (_) => OrdersScreen(highlightOrderId: orderId),
    ));
  }

  static void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          icon: '@drawable/ic_notification',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Carry FCM data so we can navigate on tap
      payload: jsonEncode(message.data),
    );
  }

  static String? _tokenPhone;


  /// Fetches the FCM token and saves it to the server. Re-uploads on token refresh.
  /// Android only — silently skipped on other platforms.
  static Future<void> uploadToken(String phone) async {
    if (phone.isEmpty || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final token = await _fcm.getToken();
      if (token != null) await ApiService.saveFcmToken(phone, token);
      if (_tokenPhone != phone) {
        _tokenPhone = phone;
        _fcm.onTokenRefresh.listen((t) => ApiService.saveFcmToken(phone, t));
      }
    } catch (_) {}
  }
}

class _AppUpdateDialog extends StatelessWidget {
  const _AppUpdateDialog({required this.version, required this.downloadUrl});

  final String version;
  final String downloadUrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Text('🔔 ', style: TextStyle(fontSize: 22)),
          Text('App Update Available'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (version.isNotEmpty && version != 'latest') ...[
            Text('Version $version is now available.',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
          ],
          const Text(
            'Please update the app to get the latest features and improvements.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later', style: TextStyle(color: Color(0xFF6B7280))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            final uri = Uri.parse(downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('Download Update'),
        ),
      ],
    );
  }
}
