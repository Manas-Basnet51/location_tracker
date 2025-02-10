import 'package:flutter/material.dart';
import 'package:task_assesment/domain/services/navigation_service.dart';

class NavigationServiceImpl implements NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey;

  NavigationServiceImpl(this._navigatorKey);

  @override
  Future<void> push(String route, {Object? arguments}) async {
    await _navigatorKey.currentState?.pushNamed(
      route,
      arguments: arguments,
    );
  }

  @override
  Future<void> pushReplacement(String route, {Object? arguments}) async {
    await _navigatorKey.currentState?.pushReplacementNamed(
      route,
      arguments: arguments,
    );
  }

  @override
  void pop<T>([T? result]) {
    _navigatorKey.currentState?.pop(result);
  }

  @override
  Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
}
