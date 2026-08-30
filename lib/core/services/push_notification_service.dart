import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Request Permission from user
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // 2. Setup Local Notifications for Foreground display
        await _setupLocalNotifications();

        // 3. Get & Register Device Token
        String? token = await _fcm.getToken();
        if (token != null) {
          await registerDeviceToken(token);
        }

        // Listen for token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          registerDeviceToken(newToken);
        });

        // 4. Foreground Message Listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _showForegroundNotification(message);
        });

        // 5. App Opened from Notification Listener
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleNotificationTap(message);
        });

        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            _navigateToAlerts(data);
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'mandi_alerts_channel',
      'Mandi Alerts',
      channelDescription: 'Push notifications for price alerts and market advisories',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/alerts/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_type': deviceType,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM Token registered successfully on backend');
      }
    } catch (e) {
      debugPrint('Failed to send FCM token to backend: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateToAlerts(message.data);
  }

  void _navigateToAlerts(Map<String, dynamic> data) {
    debugPrint('Navigating to alert payload: $data');
    // Payload contains {"screen": "/alerts", "alert_id": "...", ...}
  }
}
