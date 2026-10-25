import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Web (Chrome): sqflite biasa tidak didukung, pakai versi web
// tanpa web worker agar lebih stabil.
Future<sqflite.DatabaseFactory> getAppDatabaseFactory() async {
  return databaseFactoryFfiWebNoWebWorker;
}