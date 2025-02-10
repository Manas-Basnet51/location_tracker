import 'package:hive_ce/hive.dart';
import 'package:task_assesment/data/models/location_point.dart';

/// Handles location data persistence and retrieval.
/// 
/// Responsibilities:
/// - Manages tracking sessions
/// - Stores location points
/// - Handles track lifecycle
/// - Provides access to location history
/// - Has close box and restart box to force reload hive boxes
abstract class LocationRepository {
  Future<void> startNewTrack();
  Future<void> stopCurrentTrack();
  List<LocationPoint> getLocationHistory();
  Future<void> clearAllTracks();
  Future<void> closeBox();
  Future<void> restartBox();
  String? get currentTrackId;
  Box<LocationPoint> get locationBox;
  Box get trackIdBox;
}