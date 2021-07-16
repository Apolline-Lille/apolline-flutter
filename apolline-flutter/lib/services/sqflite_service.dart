import 'dart:io';
import 'package:apollineflutter/models/sensor_collection.dart';
import 'package:apollineflutter/models/sensormodel.dart';
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
  static final tableSensorModel = 'SensorModel';
  static final columnId = 'id';
  static final columnDeviceName = 'deviceName';
  static final columnUuid = 'uuid';
  static final columnProvider = 'provider';
  static final columnGeohash = 'geohash';
  static final columnTransport = 'transport';
  static final columnDate = 'date';
  static final columnSynchro = 'synchronisation';
  static final columnValues = 'value';

  // database table date and column names
  // static final tableDateModel = 'DateSynchronisation';
  // static final colId = 'id';
  // static final colDate = 'DateSynchro';

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
          CREATE TABLE $tableSensorModel (
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

    // String queryDate = '''
    //       CREATE TABLE $tableDateModel (
    //         $colId INTEGER PRIMARY KEY,
    //         $colDate INTEGER
    //       )
    //       ''';
    await db.execute(querySensor);
  }

  // SQL save SensorModel
  Future<Map<String, dynamic>> insertSensor(Map<String, dynamic> sensormodel) async {
    Database db = await database;
    // ignore: unused_local_variable
    var id = db.insert(tableSensorModel, sensormodel);
    return sensormodel;
  }

  // SQL save SensorModel
  Future<int> insertAllSensor(SensorCollection sensorCollection) async {
    Database db = await database;
    // ignore: unused_local_variable
    var buffer = new StringBuffer();
    sensorCollection.lastData.forEach((element) {
      Map<String, dynamic> json = element.toJSON();
      if (buffer.isNotEmpty) {
        buffer.write(",\n");
      }
      buffer.write("('");
      buffer.write(json["deviceName"]);
      buffer.write("', '");
      buffer.write(json["uuid"]);
      buffer.write("', '");
      buffer.write(json["provider"]);
      buffer.write("', '");
      buffer.write(json["geohash"]);
      buffer.write("', '");
      buffer.write(json["transport"]);
      buffer.write("', '");
      buffer.write(json["dateSynchro"]);
      buffer.write("', '");
      buffer.write(json["value"]);
      buffer.write("')");
    });
    // sensorCollection.lastData.forEach((element) async {
    //   await db.insert(tableSensorModel, element.toJSON());
    //});
    //var id = await db.insert(tableSensorModel, sensorCollection);
    var raw = await db.rawInsert("INSERT Into $tableSensorModel ($columnDeviceName, $columnUuid, $columnProvider, $columnTransport, $columnGeohash, $columnDate, $columnValues ) "
        " VALUES ${buffer.toString()}");
    return raw;
  }

  // SQL get SensorModel data by uuid
  Future<List<SensorModel>> getSensorModelByUuid(String uuid) async {
    Database db = await database;
    List<SensorModel> sensdorModels = [];
    List<Map> maps = await db.query(tableSensorModel,
        columns: [columnId, columnDeviceName, columnUuid, columnProvider, columnGeohash, columnTransport, columnValues], where: '$columnUuid = ?', whereArgs: [uuid]);
    if (maps.length > 0) {
      maps.forEach((map) => sensdorModels.add(SensorModel.fromJson(map)));
      return sensdorModels;
    }
    return sensdorModels;
  }

  // SQL get all SensorModel data
  Future<List<SensorModel>> getAllSensorModels() async {
    Database db = await database;
    List<SensorModel> sensdorModels = [];
    List<Map> maps = await db.query(tableSensorModel);
    if (maps.length > 0) {
      maps.forEach((map) => sensdorModels.add(SensorModel.fromJson(map)));
      return sensdorModels;
    }
    return sensdorModels;
  }

  // SQL get all SensorModelNotSynchro data
  Future<List<SensorModel>> getAllSensorModelsNotSyncro() async {
    Database db = await database;
    List<SensorModel> sensdorModels = [];
    List<Map> maps = await db.query(tableSensorModel,
        columns: [columnId, columnDeviceName, columnUuid, columnProvider, columnGeohash, columnTransport, columnDate, columnValues], where: '$columnSynchro == ?', whereArgs: [0]);
    if (maps.length > 0) {
      maps.forEach((map) => sensdorModels.add(SensorModel.fromJson(map)));
      return sensdorModels;
    }
    return sensdorModels;
  }

  ///
  ///get all data after this mapfrequency [freq].
  Future<List<SensorModel>> getAllSensorModelAfterDate(MapFrequency freq) async {
    List<SensorModel> sensorModels = [];
    var now = DateTime.now();
    List<int> freqC = [1, 5, 15, 30, 60, 180, 360, 720, 1440]; //convert to minute.
    var today = now.hour*60 + now.minute;
    var thisweek = (now.weekday - 1) * 24 * 60 + today;
    freqC.add(today);
    freqC.add(thisweek);
    var time = now.millisecondsSinceEpoch - 60000*freqC[freq.index];

    Database db = await database;
    var jsonres = await db.query(tableSensorModel, columns: null, where: "$columnDate >= ?", whereArgs: [time]);
    jsonres.forEach((pJson) { sensorModels.add(SensorModel.fromJson(pJson)); });
    
    return sensorModels;
  }


  // SQL update Sensor colunm synchronisation
  Future updateSensorSynchronisation(List<int> ids) async {
    Database db = await database;
    // ignore: unused_local_variable.
    String inClause = ids.toString();
    //at this point inClause will look like "[1,2,3,4,5]"
    //replace the brackets with parentheses
    inClause = inClause.replaceFirst("[","(");
    inClause = inClause.replaceFirst("]",")");
    //at this point inClause will look like "(1,2,3,4,5)"
    String query = ''' UPDATE $tableSensorModel SET $columnSynchro = 1 WHERE id IN '''+inClause;
    await db.execute(query);
  }

  // SQL delete all data
  Future<int> deleteAllSensorData() async {
    Database db = await database;
    return await db.delete(tableSensorModel);
  }

  // SQL close database
  Future close() async {
    Database db = await database;
    db.close();
  }
}
