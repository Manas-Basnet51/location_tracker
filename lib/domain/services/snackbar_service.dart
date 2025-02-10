import 'package:flutter/material.dart';

abstract class SnackbarService {
  void showError({
    required String message,
    SnackBarAction? action,
  });
  void showSuccess({
    required String message,
    SnackBarAction? action,
  });
  void showInfo({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  });
}