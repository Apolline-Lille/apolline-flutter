import 'dart:async';

import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'package:apollineflutter/services/location_service.dart';
import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/twins/SensorTwinEvent.dart';
import 'package:apollineflutter/utils/SensorCommands.dart';
import 'package:apollineflutter/utils/position.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../gattsample.dart';



///
/// This class acts as a digital twin for air quality sensors.
///
/// Through it, a sensor can be activated, clock-synchronized with a phone,
/// and asked to transmit data.
///
/// Data can be received in two ways:
///   * live; sensor sends data in real time (approximately one point per second)
///   * history; sensor sends all data it gathered in the past.
///
/// To access these data, one can subscribe to data events using the "on" method.
///
class SensorTwin {
  BluetoothCharacteristic _characteristic;
  BluetoothDevice _device;
  bool _isSendingData;
  bool _isSendingHistory;
  Timer _historyTimer;
  Stopwatch _historyTimeCounter;
  List<DataPointModel> _models = [];
  Map<SensorTwinEvent, SensorTwinEventCallback> _callbacks;

  // use for influxDB to send data to the back
  InfluxDBAPI _service;
  SqfLiteService _sqfLiteService;
  Duration _synchronizationTiming;
  RealtimeDataService _dataService = locator<RealtimeDataService>();
  Timer _syncTimer;

  SimpleLocationService _locationService;
  StreamSubscription _locationSubscription;
  Position _currentPosition;
  bool _isUsingSatellitePositioning;

  SensorTwin({@required BluetoothDevice device, @required Duration syncTiming}) {
    this._device = device;
    this._isSendingData = false;
    this._isSendingHistory = false;
    this._callbacks = Map();
    this._service = InfluxDBAPI();
    this._sqfLiteService = SqfLiteService();
    this._synchronizationTiming = syncTiming;
    this._isUsingSatellitePositioning = false;
  }


  String get name {
    return this._device.name;
  }


  /// Starts sending data live (one point every second) through Bluetooth
  /// connection.
  /// Does nothing if data transmission is already in progress.
  Future<void> launchDataLiveTransmission () {
    if (_isSendingData) return null;
    _isSendingData = true;

    return _characteristic.write([0x63, 0]).then((s) {
      print("Requested streaming start");
    }).catchError((e) {
      print(e);
    });
  }

  /// Stops sending data.
  /// Does nothing if data transmission is not in progress.
  Future<void> stopDataLiveTransmission () {
    _isSendingData = false;

    return _characteristic.write(List.from(SensorCommands.disableLiveData)..add(0)).then((s) {
      print("Live data transmission stopped");
    }).catchError((e) {
      print(e);
    });
  }


  /// Starts sending data stored on the SD card.
  /// Does nothing if history transmission is already in progress.
  launchHistoryTransmission () async {
    if(_isSendingHistory) return null;
    _isSendingHistory = true;
    _readSensorSD();
    _setPeriodicData();
  }

  /// Calls when the reading is over.
  ///
  /// Deletes file in the sensor (to avoid reading too much data and data already treated).
  /// Computes the averages values during the period and call the callback method for the history transmission mode.
  void _historyTreatment() {
    _characteristic.write(SensorCommands.deleteSDData)
        .then(
            (value) => print("Deleting old sensor data..."))
        .catchError(
            (error) => print("Error when deleting old sensor data : $error"));

    DataPointModel averagesValues = _computeAveragesValues();
    _models = [];
    _callbacks[SensorTwinEvent.history_data](averagesValues);
  }

  DataPointModel _computeAveragesValues() {
    double averagePM1 = 0,
        averagePM2_5 = 0,
        averagePM10 = 0,
        averagePMAbove0_3 = 0,
        averagePMAbove0_5 = 0,
        averagePMAbove1 = 0,
        averagePMAbove2_5 = 0,
        averagePMAbove5 = 0,
        averagePMAbove10 = 0,
        averageTemp = 0,
        averageHumidity = 0;

    int length = _models.length;
    DataPointModel last = _models.last;
    List<String> values = last.values;

    // computes total of sensor values
    _models.forEach((DataPointModel dpm) {
      averagePM1 += dpm.pm1value;
      averagePM2_5 += dpm.pm25value;
      averagePM10 += dpm.pm10value;
      averagePMAbove0_3 += dpm.pmAbove03value;
      averagePMAbove0_5 += dpm.pmAbove05value;
      averagePMAbove1 += dpm.pmAbove1value;
      averagePMAbove2_5 += dpm.pmAbove25value;
      averagePMAbove5 += dpm.pmAbove5value;
      averagePMAbove10 += dpm.pmAbove10value;
      averageTemp += dpm.temperature;
      averageHumidity += dpm.humidity;
    });

    // computes average of all of these values.
    averagePM1 /= length;
    averagePM2_5 /= length;
    averagePM10 /= length;
    averagePMAbove0_3 /= length;
    averagePMAbove0_5 /= length;
    averagePMAbove1 /= length;
    averagePMAbove2_5 /= length;
    averagePMAbove5 /= length;
    averagePMAbove10 /= length;
    averageTemp /= length;
    averageHumidity /= length;

    values.replaceRange(
        DataPointModel.SENSOR_PM_1,
        DataPointModel.SENSOR_PM_ABOVE_10 + 1,
        [
          averagePM1.toString(),
          averagePM2_5.toString(),
          averagePM10.toString(),
          averagePMAbove0_3.toString(),
          averagePMAbove0_5.toString(),
          averagePMAbove1.toString(),
          averagePMAbove2_5.toString(),
          averagePMAbove5.toString(),
          averagePMAbove10.toString()
        ]
    );

    values.replaceRange(
        DataPointModel.SENSOR_TEMP,
        DataPointModel.SENSOR_HUMI + 1,
        [
          averageTemp.toString(),
          averageHumidity.toString()
        ]);

    // creates point with averages at the last position and last date.
    return _getPointWithPosition(values);
  }

  /// Synchronises internal clock with phone's time.
  Future<void> synchronizeClock () {
    print("Synchronizing clock");
    String command = "i";
    DateTime now = DateTime.now();
    String time = "${now.hour};${now.minute};${now.second};${now.day};${now.month};${now.year}";
    String clockCommand = "$command$time";

    // converting command to bytes
    List<int> clockCommandBytes = clockCommand.codeUnits;
    // adding NULL at the end of the command
    List<int> finalCommand = new List.from(clockCommandBytes)..addAll([0x0]);

    return _characteristic.write(finalCommand)
        .then((value) { return value; })
        .catchError((e) { print('ERROR WHILE SYNCHRONIZING CLOCK: $e'); });
  }


  /// Registers a function to be called when new data is produced.
  void on (SensorTwinEvent event, SensorTwinEventCallback callback) {
    _callbacks[event] = callback;
  }


  /// Redistributes sensor data to registered callbacks.
  Future<void> _setUpListeners () {
    _device.state.listen((state) {
      switch(state) {
        case BluetoothDeviceState.connected:
          if (_callbacks.containsKey(SensorTwinEvent.sensor_connected))
            _callbacks[SensorTwinEvent.sensor_connected]("connected");
          break;
        case BluetoothDeviceState.disconnected:
          if (_callbacks.containsKey(SensorTwinEvent.sensor_disconnected))
            _callbacks[SensorTwinEvent.sensor_disconnected]("disconnected");
          break;
        default:
          break;
      }
    });

    bool isEndOfFile = false; // for periodic live transmission mode.

    return _characteristic.setNotifyValue(true).then((s) {
      /* Catch updates on characteristic  */
    }).catchError((e) {
      print(e);
    }).whenComplete(() {

      _characteristic.value.listen((value) async {
        String message = String.fromCharCodes(value);
        if (_isSendingData && _callbacks.containsKey(SensorTwinEvent.live_data)) {
          DataPointModel model = _handleSensorUpdate(message);
          _callbacks[SensorTwinEvent.live_data](model);
        } else if (_isSendingHistory && _callbacks.containsKey(SensorTwinEvent.history_data)) {
          DataPointModel model = _handleSensorUpdate(message);
          if(model != null) _models.add(model);
          if(value.length == 2 && value[0] == 13 && value[1] == 10) { // this line is the `Carriage Return` and `Line Feed` characters. In each file stored in the sensor, this line appear twice
            if(isEndOfFile)
              _historyTreatment();

            isEndOfFile = !isEndOfFile;
          }
        }
      });
    });
  }


  /// Filters out a Bluetooth device's services and characteristics to find the
  /// one that will allow us to receive data from the sensor.
  Future<bool> _loadUpSensorCharacteristic () async {
    List<BluetoothService> services = await _device.discoverServices();
    Iterable<BluetoothService> sensorServices = services.where((service) => service.uuid.toString().toLowerCase() == BlueSensorAttributes.dustSensorServiceUUID);
    if (sensorServices.length == 0) {
      return false;
    }
    BluetoothService sensorService = sensorServices.first;
    BluetoothCharacteristic characteristic = sensorService.characteristics.firstWhere((char) => char.uuid.toString().toLowerCase() == BlueSensorAttributes.dustSensorCharacteristicUUID);
    this._characteristic = characteristic;
    return true;
  }

  void _startLocationService () {
    this._locationSubscription = this._locationService.locationStream.listen((p) {
      this._currentPosition = p;
    });
  }
  void _stopLocationService() {
    this._locationSubscription?.cancel();
    this._locationSubscription = null;
    this._locationService.close();
  }

  void _initSynchronizationTimer () {
    this._syncTimer = Timer.periodic(_synchronizationTiming, (Timer t) => _synchronizationCallback());
  }

  /// Retrieves all data points from local database that have not been sent
  /// to InfluxDB yet, and sends them.
  /// Points that have been sent to backend are marked as synchronized, and are
  /// deleted from local database if they're more than one-week-old.
  void _synchronizationCallback () async {
    // find not-synchronized data
    List<DataPointModel> dataPoints = await _sqfLiteService.getNotSynchronizedModels();
    if (dataPoints.length == 0) return;


    // if a lot of data points have not been sent to the backend, we avoid
    // doing a HTTP call with a giant payload; we rather use several HTTP calls
    // each containing MAX_MODELS_COUNT models.
    const int MAX_MODELS_COUNT = 150;
    int modelsCount = dataPoints.length;
    int callsCount = (modelsCount/MAX_MODELS_COUNT).ceil();

    for (int i=0; i<callsCount; i++) {
      int lowerBound = i * MAX_MODELS_COUNT;
      int upperBound = i == callsCount - 1
          ? modelsCount
          : lowerBound + MAX_MODELS_COUNT;

      // Send data to influxDB
      List<DataPointModel> models = dataPoints.sublist(lowerBound, upperBound);
      print('Sending ${models.length} data points to InfluxDB');
      await _service.write(DataPointModel.sensorsFmtToInfluxData(models));

      // Update local data in sqfLite
      List<int> ids = models.map((model) => model.id).toList();
      await _sqfLiteService.setModelsAsSynchronized(ids);
    }

    // Avoiding using too much disk space
    _sqfLiteService.removeOldModels();
  }

  _setPeriodicData({Duration duration = const Duration(minutes: 5)}) {
    _historyTimer = Timer.periodic(duration, (timer) {
      _readSensorSD();
    });
  }

  _readSensorSD() {
    _characteristic.write(new List.from(SensorCommands.readingSD)..add(0))
        .then(
            (value) => print("Reading SD content"))
        .catchError(
            (onError) => print('Error when reading sensor SD content : $onError'));
  }

  /// Called when data is received from the sensor
  DataPointModel _handleSensorUpdate (String message) {
    if (!message.contains('\n') || ";".allMatches(message).length != 21) return null;
    print("Got full line: " + message);
    DataPointModel model = this._getPointWithPosition(message.split(';'));
    _dataService.update(model);
    /* insert to sqflite */
    _sqfLiteService.addDataPoint(model.toJSON());

    return model;
  }

  /// Returns a data point with the current location.
  /// Current location is either:
  ///   * sensor location, if it currently has access to GPS signal;
  ///   * phone location otherwise.
  ///
  /// If 3 satellites or more are accessible by the sensor, this will switch
  /// to using sensor locations, and will turn off phone location service to
  /// save battery usage.
  /// Else, phone location service is started.
  DataPointModel _getPointWithPosition (List<String> values) {
    double sensorLongitude = double.parse(values[DataPointModel.SENSOR_LONGITUDE]);
    double sensorLatitude = double.parse(values[DataPointModel.SENSOR_LATITUDE]);
    double satellitesCount = double.parse(values[DataPointModel.SENSOR_GPS_SATELLITES_COUNT]);

    Position currentPosition;
    bool shouldUseSatellitePositioning = satellitesCount >= 3 && sensorLongitude != 0 && sensorLatitude != 0;

    if (shouldUseSatellitePositioning) {
      currentPosition = Position(
          provider: "sensor",
          geohash: SimpleGeoHash.encode(sensorLatitude, sensorLongitude));
      if (!this._isUsingSatellitePositioning) {
        this._isUsingSatellitePositioning = true;
        _stopLocationService();
      }
    } else {
      currentPosition = _currentPosition;
      if (this._isUsingSatellitePositioning) {
        this._isUsingSatellitePositioning = false;
        this._locationService.start();
        _startLocationService();
      }
    }

    print('Using position from ${shouldUseSatellitePositioning ? 'satellites' : 'phone'}.');

    return DataPointModel(values: values, sensorName: this.name, position: currentPosition);
  }

  /// Sets up listeners and synchronises sensor clock.
  /// Must be called before starting data transmission.
  Future<bool> init () async {
    bool serviceFound = await _loadUpSensorCharacteristic();
    if (!serviceFound)
      return false;

    await _setUpListeners();
    await synchronizeClock();

    this._locationService = SimpleLocationService();
    this._locationService.start();
    _startLocationService();

    _initSynchronizationTimer();
    return true;
  }

  /// Releases resources associated with the sensor.
  void shutdown () {
    this._callbacks = Map();
    this._syncTimer?.cancel();
    this._historyTimer?.cancel();
    this._historyTimeCounter?.stop();
    this._service.client?.close();
    this._dataService?.stop();
    _stopLocationService();
    try {
      this._device.disconnect();
    } catch (err) {
      print("Couldn't disconnect from sensor (probably because it is not reachable).");
    }
  }
}