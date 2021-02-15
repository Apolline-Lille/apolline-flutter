import 'package:apollineflutter/models/sensormodel.dart';

/// abstract class
/// realtimedataService a service to stream sensormodel
abstract class RealtimeDataService {
  Stream<SensorModel> dataStream;

  /// close Stream
  void closeDataStream();
  /// update Stream when we recieve a new model
  void update(SensorModel newValues);
  /// start recieve model
  void start();
  /// stop recieve model
  void stop();
  bool isRunning;
  List<String> currentValues;
}
