import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'browser_location_stub.dart'
    if (dart.library.js_interop) 'browser_location_web.dart'
    as browser_location;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(LoopLoomApp(initialLocation: browser_location.currentLocation()));
}
