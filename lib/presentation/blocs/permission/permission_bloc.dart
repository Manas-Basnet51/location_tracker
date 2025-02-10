

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<PermissionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
