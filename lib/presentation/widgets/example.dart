import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_assesment/core/utils/dependency_injection.dart';
import 'package:task_assesment/domain/repositories/background_service_repository.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  Future<void> _startServiceWithPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      getIt<BackgroundServiceRepository>().startService();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission required to start service.'),
        ),
      );
    }
  }
  Future<void> _stopService() async {

      getIt<BackgroundServiceRepository>().stopService();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: _startServiceWithPermissions,
              child: const Text('Start Service'),
            ),
            TextButton(
              onPressed: _stopService,
              child: const Text('Stop Service'),
            ),
          ],
        ),
      ),
    );
  }
}