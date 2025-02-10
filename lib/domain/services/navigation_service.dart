import 'package:flutter/material.dart';

abstract class NavigationService {
  Future<void> push(String route, {Object? arguments});
  Future<void> pushReplacement(String route, {Object? arguments});
  Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  });
  void pop<T>([T? result]);
}