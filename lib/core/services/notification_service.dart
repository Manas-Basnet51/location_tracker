import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_assesment/core/constants/notification_constants.dart';


class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings = 
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings = 
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await notificationsPlugin.initialize(initializationSettings);
    
    if (Platform.isAndroid) {
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        importance: Importance.high,
        playSound: false,
        showBadge: false,
        enableVibration: false,
      );
      
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(channel);
    }
  }

  NotificationDetails get _notificationDetails => NotificationDetails(
    android: AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      enableVibration: false,
      playSound: false,
      channelShowBadge: false,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  Future<void> showLocationTrackingNotification({
    String title = NotificationConstants.defaultTitle,
    String body = NotificationConstants.defaultBody,
  }) async {
    await notificationsPlugin.show(
      NotificationConstants.notificationId,
      title,
      body,
      _notificationDetails,
    );
  }
}