class LocationUpdate {
  final String trackId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationUpdate({
    required this.trackId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}