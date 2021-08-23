import 'dart:io';
import 'package:apollineflutter/models/data_point_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apollineflutter/models/user_configuration.dart';

// Author GDISSA Ramy
// Sqflite Database
class SqfLiteService {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "apolline.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;
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
  ///get all data after this mapfrequency [freq].
  Future<List<DataPointModel>> getAllDataPointsAfterDate(MapFrequency freq) async {
    List<DataPointModel> models = [];
    var now = DateTime.now();
    List<int> freqC = [1, 5, 15, 30, 60, 180, 360, 720, 1440]; //convert to minute.
    var today = now.hour*60 + now.minute;
    var thisweek = (now.weekday - 1) * 24 * 60 + today;
    freqC.add(today);
    freqC.add(thisweek);
    var time = now.millisecondsSinceEpoch - 60000*freqC[freq.index];

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


  // SQL close database
  Future close() async {
    Database db = await database;
    db.close();
  }
}
