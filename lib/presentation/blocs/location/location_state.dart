part of 'location_bloc.dart';

@immutable
sealed class LocationState extends Equatable{
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}
class LocationDataLoaded extends LocationState {
  final List<LocationPoint> locationHistory;
  const LocationDataLoaded({required this.locationHistory});

  @override
  List<Object> get props => [locationHistory];

}