import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> requestLocationPermission();
  Future<bool> requestCameraPermission();
  Future<bool> requestNotificationPermission();
  Future<bool> requestMultiplePermissions(List<Permission> permissions);
  Future<PermissionStatus> checkPermissionStatus(Permission permission);
  Future<bool> openAppSetting();
}