import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:task_assesment/core/services/notification_service.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/data/repositories/background_service_repository_impl.dart';
import 'package:task_assesment/data/repositories/location_repository_impl.dart';
import 'package:task_assesment/domain/repositories/background_service_repository.dart';
import 'package:task_assesment/domain/repositories/location_repository.dart';
import 'package:task_assesment/presentation/blocs/background_service/background_service_bloc.dart';
import 'package:task_assesment/presentation/blocs/location/location_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Hive Boxes
  final locationBox = Hive.box<LocationPoint>('location_points');
  final trackIdBox = Hive.box('live_trackId');

  // Repositories
  getIt.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(
    locationBox: locationBox,
    trackIdBox: trackIdBox,
  ));
  getIt.registerLazySingleton<BackgroundServiceRepository>(() => BackgroundServiceRepositoryImpl(
    service: getIt<FlutterBackgroundService>(),
    notificationService: getIt<NotificationService>(),
  ));

  // Services
  getIt.registerLazySingleton<FlutterBackgroundService>(() => FlutterBackgroundService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // BLoCs/Cubits
  getIt.registerLazySingleton(() => LocationBloc(locationRepository: getIt<LocationRepository>()));
  getIt.registerLazySingleton(() => BackgroundServiceBloc(
    getIt<BackgroundServiceRepository>(),
    getIt<LocationRepository>(),
    getIt<LocationBloc>(),
  ));
}
