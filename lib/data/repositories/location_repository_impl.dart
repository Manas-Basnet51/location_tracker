import 'package:hive_ce/hive.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/domain/repositories/location_repository.dart';


/// Implementation of [LocationRepository]
class LocationRepositoryImpl implements LocationRepository {
  @override
  Box<LocationPoint> locationBox;
  @override
  Box trackIdBox;

  LocationRepositoryImpl({
    required this.locationBox,
    required this.trackIdBox,
  });

  @override
  Future<void> startNewTrack() async {
    final trackId = DateTime.now().toIso8601String();
    await trackIdBox.put('currentTrackId', trackId);
  }

  @override
  Future<void> stopCurrentTrack() async {
    await trackIdBox.delete('currentTrackId');
  }

  @override
  List<LocationPoint> getLocationHistory() => locationBox.values.toList();

  @override
  Future<void> clearAllTracks() async {
    await locationBox.clear();
    await trackIdBox.clear();
  }

  @override
  String? get currentTrackId => trackIdBox.get('currentTrackId');
  
  @override
  Future<void> closeBox() async {
    await locationBox.close();
    await trackIdBox.close();
  }
  
  @override
  Future<void> restartBox() async{
    await Hive.openBox<LocationPoint>('location_points');
    await Hive.openBox('live_trackId');
    locationBox = Hive.box<LocationPoint>('location_points');
    trackIdBox = Hive.box('live_trackId');
  }
}