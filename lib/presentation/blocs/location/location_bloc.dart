import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/data/models/location_point.dart';
import 'package:task_assesment/domain/repositories/location_repository.dart';

part 'location_event.dart';
part 'location_state.dart';

/// Manages the state of location points/data on the UI level.
/// 
/// Responsibilities:
/// - Emits LocationHistoryUpdated event on every new location update
/// - Hard refreshes hive boxes using [LocationRepository] to syncronize data between background service and UI(threads)
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository locationRepository;

  LocationBloc({required this.locationRepository}) : super(LocationInitial()) {
    log('Manas');
    on<LocationHistoryUpdated>(_updateLocationHistory);
    on<ClearAllTracks>(_clearAllTracks);
  }

  Future<void> _clearAllTracks(
    ClearAllTracks event,
    Emitter<LocationState> emit
  ) async{
    locationRepository.clearAllTracks();
    add(LocationHistoryUpdated());
  }
  Future<void> _updateLocationHistory(
    LocationHistoryUpdated event,
    Emitter<LocationState> emit
  ) async{
    await _reloadHiveBox();
    emit(LocationDataLoaded(locationHistory: locationRepository.getLocationHistory()));
  }

  Future<void> _reloadHiveBox() async {
    await locationRepository.closeBox();
    await locationRepository.restartBox();
  }
}