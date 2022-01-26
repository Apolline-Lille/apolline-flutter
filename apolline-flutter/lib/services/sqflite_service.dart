import 'dart:io';
import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/models/server_model.dart';
import 'package:apollineflutter/utils/time_filter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


// Author GDISSA Ramy
// Sqflite Database
class SqfLiteService {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "apolline.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 3;
  // database table sensor and column names
  static final dataPointTableName = 'DataPointModel';
  static final columnId = 'id';
  static final columnDeviceName = 'deviceName';
  static final columnUuid = 'uuid';
  static final columnProvider = 'provider';
  static final columnGeohash = 'geohash';
  static final columnTransport = 'transport';
  static final columnDate = 'date';
  static final columnSynchro = 'synchronisation';
  static final columnValues = 'value';

  // database table server endpoints and column names
  static final serverEndpointTableName = 'ServerEndpointModel';
  static final columnApiUrl = 'apiUrl';
  static final columnPingUrl = 'pingUrl';
  static final columnPassword = 'password';
  static final columnUsername = 'username';
  static final columnDBName = 'dbName';
  static final columnIsDefault = "isDefault";

  // Make this a singleton class.
  SqfLiteService._privateConstructor();
  static final SqfLiteService _instance = SqfLiteService._privateConstructor();

  ///factory
  factory SqfLiteService() {
    return _instance;
  }

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

// open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database, can also add an onUpdate callback parameter.
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    String querySensor = '''
          CREATE TABLE $dataPointTableName (
            $columnId INTEGER PRIMARY KEY,
            $columnDeviceName TEXT NOT NULL,
            $columnUuid TEXT NOT NULL,
            $columnProvider TEXT NOT NULL,
            $columnTransport TEXT NOT NULL,
            $columnGeohash TEXT NOT NULL,
            $columnDate INTEGER NOT NULL,
            $columnSynchro INTEGER NOT NULL DEFAULT 0,
            $columnValues TEXT NOT NULL
          )
          ''';
    await db.execute(querySensor);
    querySensor = '''
       CREATE TABLE $serverEndpointTableName (
        $columnApiUrl TEXT NOT NULL PRIMARY KEY,
        $columnPingUrl TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnUsername TEXT NOT NULL,
        $columnDBName TEXT NOT NULL,
        $columnIsDefault INTEGER DEFAULT 0
      )
    ''';

    await db.execute(querySensor);
  }

  // SQL save DataPointModel
  Future<Map<String, dynamic>> addDataPoint(Map<String, dynamic> model) async {
    Database db = await database;
    // ignore: unused_local_variable
    var id = db.insert(dataPointTableName, model);
    return model;
  }

  // SQL get all DataPointModel data
  Future<List<DataPointModel>> getAllDataPoints() async {
    Database db = await database;
    List<DataPointModel> models = [];
    List<Map> maps = await db.query(dataPointTableName);
    if (maps.length > 0) {
      maps.forEach((map) => models.add(DataPointModel.fromJson(map)));
      return models;
    }
    return models;
  }


  ///
  ///get all data included in [filter] value.
  Future<List<DataPointModel>> getAllDataPointsAfterDate(TimeFilter filter) async {
    List<DataPointModel> models = [];
    var time = DateTime.now().millisecondsSinceEpoch - 60000*filter.toMinutes();
    Database db = await database;

    var jsonres = await db.query(dataPointTableName, columns: null, where: "$columnDate >= ?", whereArgs: [time]);
    jsonres.forEach((pJson) { models.add(DataPointModel.fromJson(pJson)); });

    return models;
  }


  /// Returns all models that have not been sent to backend yet
  /// (materialized with $columnSynchro == 0).
  Future<List<DataPointModel>> getNotSynchronizedModels() async {
    Database db = await database;
    List<Map> maps = await db.query(dataPointTableName,
        columns: [columnId, columnDeviceName, columnUuid, columnProvider, columnGeohash, columnTransport, columnDate, columnValues],
        where: '$columnSynchro == ?', whereArgs: [0]);
    return maps.map((map) => DataPointModel.fromJson(map)).toList();
  }

  /// Declares a list of models as sent to the backend
  /// (sets their $columnSynchro value to 1).
  Future setModelsAsSynchronized(List<int> ids) async {
    Database db = await database;
    String query = "UPDATE $dataPointTableName SET $columnSynchro = 1 WHERE id IN (${List.filled(ids.length, '?').join(',')})";
    await db.execute(query, ids);
  }

  /// Deletes models that are more than one-week-old.
  /// Models that have not been synchronized with the backend are ignored.
  Future removeOldModels() async {
    Database db = await database;
    var time = DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch;
    int rowsCount = await db.delete(dataPointTableName, where: "$columnDate <= ? AND $columnSynchro = 1", whereArgs: [time]);
    print("Removed $rowsCount data points older than one week.");
  }

  Future<ServerModel> addServerEndpoint(ServerModel serverEndpoint) async {
    Database db = await database;
    db.insert(serverEndpointTableName, serverEndpoint.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);

    return serverEndpoint;
  }

  Future<List<ServerModel>> getAllServerEndpoints() async {
    Database db = await database;

    List<Map<String, dynamic>> res = await db.query(serverEndpointTableName, columns: null);

    return res.map<ServerModel>((Map<String, dynamic> value) {
      return ServerModel.fromJson(value);
    }).toList();
  }

  Future<ServerModel> getDefaultEndpoint() async {
    Database db = await database;
    var res = await db.query(serverEndpointTableName, columns: null, where: "$columnIsDefault = TRUE", limit: 1);
    return ServerModel.fromJson(res[0]);
  }

  Future<int> deleteAllEndpoints() async {
    Database db = await database;
    int id = await db.delete(serverEndpointTableName);
    return id;
  }

  Future<int> deleteEndpoint(ServerModel serverModel) async {
    Database db = await database;
    int id = await db.delete(serverEndpointTableName, where: "$columnApiUrl = ?", whereArgs: [serverModel.apiURL]);
    return id;
  }

  // SQL close database
  Future close() async {
    Database db = await database;
    db.close();
  }
}
