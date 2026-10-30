export 'local_database_stub.dart'
    if (dart.library.io) 'local_database_io.dart'
    if (dart.library.js_interop) 'local_database_web.dart';
