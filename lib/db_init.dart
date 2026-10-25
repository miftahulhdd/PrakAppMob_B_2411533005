// Memilih implementasi sesuai platform:
// - Android / iOS : db_init_stub.dart (tidak melakukan apa-apa, sqflite biasa)
// - Web (Chrome)  : db_init_web.dart  (memakai sqflite_common_ffi_web)
export 'db_init_stub.dart'
    if (dart.library.js_interop) 'db_init_web.dart';
