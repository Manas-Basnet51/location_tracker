import 'package:flutter/material.dart';
import 'package:task_assesment/domain/services/snackbar_service.dart';

class SnackbarServiceImpl implements SnackbarService {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  SnackbarServiceImpl(this._scaffoldKey);

  @override
  void showError({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showSuccess({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 2),
  }) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showInfo({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
