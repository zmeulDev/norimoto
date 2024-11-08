import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Initialize native android notification icon
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize native iOS notification setup
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // We'll request permissions separately
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      debugPrint('Notifications initialized successfully');
      _initialized = true;

      // Request permissions after initialization
      await requestPermissions();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      // Don't rethrow - we want the app to continue working even if notifications fail
    }
  }

  static Future<void> _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint('Received iOS notification: $title');
  }

  static void _onDidReceiveNotificationResponse(
      NotificationResponse details) async {
    debugPrint('Notification tapped: ${details.payload}');
  }

  static Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final granted =
              await androidImplementation.requestNotificationsPermission();
          debugPrint('Android notifications permission granted: $granted');
        }
      }

      if (Platform.isIOS) {
        final iosImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  static Future<void> scheduleServiceReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'service_reminders',
        'Service Reminders',
        channelDescription: 'Notifications for service reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id, // Store the service ID as payload
      );
      debugPrint('Reminder scheduled for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelReminder(String id) async {
    if (!_initialized) return;
    await _notifications.cancel(id.hashCode);
  }

  static Future<void> cancelAllReminders() async {
    if (!_initialized) return;
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    if (!_initialized) return [];
    return await _notifications.pendingNotificationRequests();
  }
}

// Add this class to handle navigation context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
