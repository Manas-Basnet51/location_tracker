import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_assesment/presentation/pages/home_page.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Location Permission Required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We need access to your location to track your movements and display them on the map.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.location.request();
                  if (status.isGranted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
