import 'package:geolocator/geolocator.dart';
import 'package:task_assesment/data/models/location_point.dart';


/// Filters location updates based on distance and time thresholds.
/// Necessary to prevent excessivce background location fetch
class LocationFilter {
  static const double minDistanceFilter = 10.0; // meters
  static const double minTimeFilter = 1000; // milliseconds
  
  static bool shouldKeepPoint(LocationPoint lastPoint, Position newPosition) {
    
    final distance = Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    final timeDiff = DateTime.now().difference(lastPoint.timestamp).inMilliseconds;
    
    return distance >= minDistanceFilter || timeDiff >= minTimeFilter;
  }
}
