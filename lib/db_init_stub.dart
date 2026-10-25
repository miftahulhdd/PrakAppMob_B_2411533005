import 'package:sqflite/sqflite.dart' as sqflite;

// Android / iOS: pakai sqflite bawaan.
Future<sqflite.DatabaseFactory> getAppDatabaseFactory() async {
  return sqflite.databaseFactory;
}
