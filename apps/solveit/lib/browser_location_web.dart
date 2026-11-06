import 'package:web/web.dart' as web;

String? currentLocation() {
  final route = web.document.documentElement?.getAttribute(
    'data-looploom-initial-route',
  );
  return route == null || route.isEmpty ? null : route;
}
