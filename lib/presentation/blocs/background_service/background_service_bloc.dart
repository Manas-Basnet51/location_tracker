import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/domain/repositories/background_service_repository.dart';
import 'package:task_assesment/domain/repositories/location_repository.dart';
import 'package:task_assesment/presentation/blocs/location/location_bloc.dart';

part 'background_service_event.dart';
part 'background_service_state.dart';


/// Manages the state of background service on the UI level.
/// 
/// Responsibilities:
/// - Tracks service status
/// - Handles start/stop operations
/// - Manages location updates
/// - Listens to [location_updated] method invoked by background service isolate which force updates location bloc by adding [LocationHistoryUpdated] event to [LocationBloc]
/// - Error handling 
/// 
/// States:
/// - BackgroundServiceInitial
/// - BackgroundServiceRunning
/// - BackgroundServiceStopped
/// - BackgroundServiceError
class BackgroundServiceBloc extends Bloc<BackgroundServiceEvent, BackgroundServiceState> {
  final BackgroundServiceRepository _service;
  final LocationRepository _locationRepo;
  final LocationBloc _locationBloc;
  StreamSubscription? _updateSubscription;
  bool _isSubscriptionActive = false;

  BackgroundServiceBloc(
    this._service,
    this._locationRepo,
    this._locationBloc,
  ) : super(BackgroundServiceInitial()) {
    debugPrint('[Background Service Bloc] listening');
    _updateSubscription = _service.listenForServiceEvents('location_updated').listen(
      (_) => add(LocationUpdateReceived()),
    );
    _updateSubscription?.pause();

    on<CheckServiceStatus>(_onCheckServiceStatus);
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<ServiceRunningDetected>(_onServiceRunningDetected);
    on<ServiceStoppedDetected>(_onServiceStoppedDetected);
    on<LocationUpdateReceived>(_onLocationUpdateReceived);
    on<ServiceError>(_onServiceError);
  }

  void _manageSubscription(bool shouldBeActive) {
    if (_isSubscriptionActive != shouldBeActive) {
      if (shouldBeActive) {
        _updateSubscription?.resume();
      } else {
        _updateSubscription?.pause();
      }
      _isSubscriptionActive = shouldBeActive;
    }
  }

  Future<void> _onCheckServiceStatus(
    CheckServiceStatus event,
    Emitter<BackgroundServiceState> emit,
  ) async {
    try {
      final isRunning = await _service.isServiceRunning();
      if (isRunning) {
        final trackId = _locationRepo.currentTrackId;
        if (trackId != null) {
          add(ServiceRunningDetected(trackId));
        } else {
          await _service.stopService();
          add(ServiceStoppedDetected());
        }
      } else {
        add(ServiceStoppedDetected());
      }
    } catch (e) {
      add(ServiceError(e.toString()));
    }
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<BackgroundServiceState> emit,
  ) async {
    try {
      await _locationRepo.startNewTrack();
      final trackId = _locationRepo.currentTrackId!;
      
      if (!await _service.isServiceRunning()) {
        await _service.startService();
      }
      
      add(ServiceRunningDetected(trackId));
    } catch (e) {
      add(ServiceError(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<BackgroundServiceState> emit,
  ) async {
    try {
      await _locationRepo.stopCurrentTrack();
      await _service.stopService();
      add(ServiceStoppedDetected());
    } catch (e) {
      add(ServiceError(e.toString()));
    }
  }

  void _onServiceRunningDetected(
    ServiceRunningDetected event,
    Emitter<BackgroundServiceState> emit,
  ) {
    _manageSubscription(true);
    emit(BackgroundServiceRunning(event.trackId));
  }

  void _onServiceStoppedDetected(
    ServiceStoppedDetected event,
    Emitter<BackgroundServiceState> emit,
  ) {
    _manageSubscription(false);
    emit(BackgroundServiceStopped());
  }

  void _onLocationUpdateReceived(
    LocationUpdateReceived event,
    Emitter<BackgroundServiceState> emit,
  ) {
    _locationBloc.add(LocationHistoryUpdated());
  }

  void _onServiceError(
    ServiceError event,
    Emitter<BackgroundServiceState> emit,
  ) {
    _manageSubscription(false);
    emit(BackgroundServiceError(event.error));
  }

  @override
  Future<void> close() async {
    await _updateSubscription?.cancel();
    return super.close();
  }
}
