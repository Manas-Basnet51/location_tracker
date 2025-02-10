import 'package:hive_ce/hive.dart';

part 'location_point.g.dart';

@HiveType(typeId: 0)
class LocationPoint extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool isOnline;

  @HiveField(4)
  final String trackId;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isOnline,
    required this.trackId,
  });
}