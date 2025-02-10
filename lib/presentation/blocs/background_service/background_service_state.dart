part of 'background_service_bloc.dart';

sealed class BackgroundServiceState extends Equatable {
  const BackgroundServiceState();
  
  @override
  List<Object> get props => [];
}

class BackgroundServiceInitial extends BackgroundServiceState {}
class BackgroundServiceRunning extends BackgroundServiceState {
  final String trackId;
  const BackgroundServiceRunning(this.trackId);
}
class BackgroundServiceStopped extends BackgroundServiceState {}
class BackgroundServiceError extends BackgroundServiceState {
  final String message;
  const BackgroundServiceError(this.message);
}