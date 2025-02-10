part of 'background_service_bloc.dart';

sealed class BackgroundServiceEvent extends Equatable {
  const BackgroundServiceEvent();

  @override
  List<Object> get props => [];
}

class CheckServiceStatus extends BackgroundServiceEvent {}

class StartTracking extends BackgroundServiceEvent {}

class StopTracking extends BackgroundServiceEvent {}

class ServiceRunningDetected extends BackgroundServiceEvent {
  final String trackId;
  const ServiceRunningDetected(this.trackId);
}

class ServiceStoppedDetected extends BackgroundServiceEvent {}

class LocationUpdateReceived extends BackgroundServiceEvent {}

class ServiceError extends BackgroundServiceEvent {
  final String error;
  const ServiceError(this.error);
}