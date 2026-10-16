import 'package:flutter/widgets.dart';

/// Rotas abertas no navegador do app (o Flutter não expõe a pilha). Fica
/// registrado no `MaterialApp` (`navigatorObservers`).
class RouteStackObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];

  /// Da base para o topo.
  List<Route<dynamic>> get routes => List.unmodifiable(_stack);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _stack.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _stack.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _stack.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      _stack[index] = newRoute;
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
  }
}

/// Observer do navegador principal.
final routeStackObserver = RouteStackObserver();

/// Abre [routeName], mas, se a mesma tela ([same] compara os argumentos) já
/// estiver na pilha, volta até ela em vez de empilhar outra. Evita o vai-e-
/// volta infinito (ex.: Atleta → Time → Atleta → Time…).
Future<void> openOrReturn(
  BuildContext context,
  String routeName, {
  Object? arguments,
  required bool Function(Object? arguments) same,
  RouteStackObserver? observer,
}) async {
  final stack = (observer ?? routeStackObserver).routes;
  for (final route in stack.reversed) {
    if (route.settings.name == routeName && same(route.settings.arguments)) {
      if (route.isCurrent) return;
      Navigator.of(context).popUntil((candidate) => candidate == route);
      return;
    }
  }
  await Navigator.of(context).pushNamed(routeName, arguments: arguments);
}
