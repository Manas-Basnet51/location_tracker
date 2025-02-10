abstract class BackgroundServiceRepository {
  Future<void> initializeService();
  Future<void> startService();
  Future<void> stopService();
  Future<bool> isServiceRunning();
  Stream<dynamic> listenForServiceEvents(String eventKey);
}