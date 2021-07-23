import 'package:apollineflutter/twins/SensorTwinEvent.dart';

class SensorTwin {
  String _uuid;
  bool _isSendingData;
  bool _isSendingHistory;
  Map<SensorTwinEvent, SensorTwinEventCallback> _callbacks;


  String get uuid {
    return this._uuid;
  }


  /// Starts sending data live (one point every second) through Bluetooth
  /// connection.
  /// Does nothing if data transmission is already in progress.
  Future<void> launchDataLiveTransmission () {}

  /// Stops sending data.
  /// Does nothing if data transmission is not in progress.
  Future<void> stopDataLiveTransmission () {}


  /// Starts sending data stored on the SD card.
  /// Does nothing is history transmission is already in progress.
  Future<void> launchHistoryTransmission () {}


  /// Synchronises internal clock with phone's time.
  Future<void> synchronizeClock () {}


  /// Registers a function to be called when new data is produced.
  void on (SensorTwinEvent event, SensorTwinEventCallback callback) {}
}