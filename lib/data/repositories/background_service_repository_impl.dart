
import 'dart:developer';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:task_assesment/core/constants/notification_constants.dart';
import 'package:task_assesment/core/utils/background_service_handler.dart';
import 'package:task_assesment/core/services/notification_service.dart';
import 'package:task_assesment/core/utils/permission_handler.dart';
import 'package:task_assesment/domain/repositories/background_service_repository.dart';

class BackgroundServiceRepositoryImpl implements BackgroundServiceRepository {
  final FlutterBackgroundService service;
  final NotificationService notificationService;

  BackgroundServiceRepositoryImpl({required this.service,required this.notificationService});

  @override
  Future<void> initializeService() async {
    log('initialize bg Service');
    await service.configure(
      androidConfiguration: _androidConfig(),
      iosConfiguration: _iosConfig(),
    );
  }

  AndroidConfiguration _androidConfig() => AndroidConfiguration(
        onStart: BackgroundServiceHandler.onStart,
        autoStart: false,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: NotificationConstants.channelId,
        initialNotificationTitle: NotificationConstants.defaultTitle,
        initialNotificationContent: NotificationConstants.defaultBody, 
        foregroundServiceNotificationId: NotificationConstants.notificationId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      );

  IosConfiguration _iosConfig() => IosConfiguration(
        autoStart: false,
        onForeground: BackgroundServiceHandler.onStart,
        onBackground: BackgroundServiceHandler.onIosBackground,
      );

  @override
  Future<void> startService() async {
    final hasPermissions = await PermissionHandler.requestLocationPermissions();
    if (!hasPermissions) {
      throw Exception('Required permissions not granted');
    }

    if (await service.isRunning()) return;
    await notificationService.showLocationTrackingNotification();
    await service.startService();
  }

  @override
  Future<void> stopService() async {
    if (await service.isRunning()) service.invoke('stop');
  }

  @override
  Future<bool> isServiceRunning() => service.isRunning();

  @override
  Stream<dynamic> listenForServiceEvents(String eventKey) => service.on(eventKey);
}
