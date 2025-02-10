import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestLocationPermissions() async {
    final status = await Permission.locationAlways.status;
    
    if (status.isDenied) {
      final result = await Permission.locationAlways.request();
      if (result.isDenied) return false;
    }
    
    if (Platform.isAndroid) {
      final fgStatus = await Permission.notification.status;
      if (fgStatus.isDenied) {
        final result = await Permission.notification.request();
        if (result.isDenied) return false;
      }
    }
    
    return true;
  }
}
