import 'package:flutter/material.dart';

class CustomRouteObserver extends NavigatorObserver {
  List<Route> routeStack = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    routeStack.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    routeStack.removeLast();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routeStack.remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    routeStack.removeLast();

    if (newRoute != null) {
      routeStack.add(newRoute);
    }
  }

  Route? get currentRoute => routeStack.isNotEmpty ? routeStack.last : null;
  Route? get previousRoute =>
      routeStack.length > 1 ? routeStack[routeStack.length - 2] : null;
}
