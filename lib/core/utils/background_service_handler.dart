import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:task_assesment/core/utils/location_filter.dart';
import 'package:task_assesment/data/models/location_point.dart';


/// Manages background location tracking functionality.
/// 
/// Responsibilities:
/// - Handles location updates in background
/// - Manages periodic tasks
/// - Handles service lifecycle
/// - Persists location data
@pragma('vm:entry-point')
class BackgroundServiceHandler {

  BackgroundServiceHandler._();
  static final BackgroundServiceHandler _instance = BackgroundServiceHandler._();
  static BackgroundServiceHandler get instance => _instance;


  static const _periodicTaskInterval = Duration(seconds: 10);
  
  Timer? _periodicTimer;

  StreamSubscription<Position>? _locationStream;
  LocationPoint? _lastPoint;

  @pragma('vm:entry-point')
  Future<void> _startLocationTracking(ServiceInstance service) async {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // meters
    );
    
    _locationStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      try {
        await _handleLocationUpdate(position, service);
      } catch (e) {
        debugPrint('[SERVICE] Location update error: $e');
      }
    });
  }

  Future<void> _handleLocationUpdate(Position position, ServiceInstance service) async {
    final trackIdBox = Hive.box('live_trackId');
    final trackId = trackIdBox.get('currentTrackId');
    
    if (trackId == null) return;
    
    final locationBox = Hive.box<LocationPoint>('location_points');
    final newPoint = LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      isOnline: true,
      trackId: trackId,
    );

    if (_lastPoint == null || LocationFilter.shouldKeepPoint(_lastPoint!, position)) {
      await locationBox.add(newPoint);
      await locationBox.flush();
      _lastPoint = newPoint;
      service.invoke('location_updated');
      
      // if (service is AndroidServiceInstance) {
      //   service.setForegroundNotificationInfo(
      //     title: 'Location Tracking',
      //     content: 'Latest: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      //   );
      // }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    try {
      debugPrint('[SERVICE] Starting');
      await _initializeFlutter();
      await instance._handleServiceStart(service);
    } catch (e, stack) {
      debugPrint('[SERVICE] Error: $e\n$stack');
      await service.stopSelf();
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    await _initializeFlutter();
    await instance._handleIosBackground();
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> _initializeFlutter() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(LocationPointAdapter());
    await Hive.openBox<LocationPoint>('location_points');
    await Hive.openBox('live_trackId');
  }

  Future<void> _handleServiceStart(ServiceInstance service) async {
    debugPrint('[SERVICE] Trying to start');
    try {
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'Location Tracking Active',
          content: 'Monitoring your location in background',
        );
        
        await service.setAsForegroundService();
      }

      _configureServiceListeners(service);
      await _startLocationTracking(service);
      await _startPeriodicTasks(service);
    } catch (e) {
      debugPrint('[SERVICE] Start error: $e');
      await _stopService(service);
      rethrow;
    }
  }

  void _configureServiceListeners(ServiceInstance service) {
    debugPrint('[SERVICE] Listens to stop events');
    service.on('stop').listen((_) async {
      await _cleanupAndStop(service);
    });

    if(service is AndroidServiceInstance) {
      debugPrint('[SERVICE] Listens to foreground events');
      service.on('setAsForeground').listen((_) async {
        
        await service.setAsForegroundService();
        debugPrint('[SERVICE] Set as foreground');
      });
      debugPrint('[SERVICE] Listens to background events');
      service.on('setAsBackground').listen((_) async {
        
        await service.setAsBackgroundService();
        debugPrint('[SERVICE] Set as background');
      });
    }
    
  }

  Future<void> _cleanupAndStop(ServiceInstance service) async {
    await _locationStream?.cancel();
    _lastPoint = null;
    _cancelPeriodicTasks();
    await _stopService(service);
  }
  

  Future<void> _stopService(ServiceInstance service) async {
    try {
      await service.stopSelf();
      debugPrint('[SERVICE] Stopped successfully');
    } catch (e) {
      debugPrint('[SERVICE] Stop error: $e');
      rethrow;
    }
  }

  Future<void> _startPeriodicTasks(ServiceInstance service) async {
    debugPrint('[SERVICE] Periodic task entry point');
    _cancelPeriodicTasks();
    
    _periodicTimer = Timer.periodic(_periodicTaskInterval, (_) async {
      try {
        debugPrint('[SERVICE] Periodic task running');
        await _executePeriodicTasks(service);
      } catch (e) {
        debugPrint('[SERVICE] Periodic task error: $e');
      }
    });
  }

  void _cancelPeriodicTasks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
  
  Future<void> _executePeriodicTasks(ServiceInstance service) async {
    try {
      final position = await _getCurrentLocation();
      await _handleLocationUpdate(position, service);
    } catch (e) {
      debugPrint('Background task error: $e');
    }
  }


  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleIosBackground() async {
  }
}