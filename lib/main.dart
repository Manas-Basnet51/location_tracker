import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:task_assesment/core/services/notification_service.dart';
import 'package:task_assesment/core/utils/dependency_injection.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/domain/repositories/background_service_repository.dart';
import 'package:task_assesment/presentation/blocs/background_service/background_service_bloc.dart';
import 'package:task_assesment/presentation/blocs/location/location_bloc.dart';
import 'package:task_assesment/presentation/pages/permission_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(LocationPointAdapter());
  await Hive.openBox<LocationPoint>('location_points');
  await Hive.openBox('live_trackId');

  setupDependencies();
  await getIt<NotificationService>().initNotification();
  await getIt<BackgroundServiceRepository>().initializeService();
  getIt<BackgroundServiceBloc>().add(CheckServiceStatus());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<LocationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<BackgroundServiceBloc>(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Location Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const PermissionPage(),
      ),
    );
  }
}
