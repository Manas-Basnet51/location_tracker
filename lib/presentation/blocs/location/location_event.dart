part of 'location_bloc.dart';

@immutable
sealed class LocationEvent extends Equatable{
  const LocationEvent();
  
  @override
  List<Object> get props => [];
}

class LocationHistoryUpdated extends LocationEvent {}
class ClearAllTracks extends LocationEvent {}
