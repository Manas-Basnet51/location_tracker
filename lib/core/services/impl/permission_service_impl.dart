import 'package:permission_handler/permission_handler.dart';
import 'package:task_assesment/domain/services/permission_service.dart';

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestMultiplePermissions(List<Permission> permissions) async {
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final status = await permission.status;
    return status;
  }

  @override
  Future<bool> openAppSetting() {
    return openAppSettings();
  }
}