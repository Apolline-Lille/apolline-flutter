import 'package:apollineflutter/models/sensormodel.dart';

abstract class RealtimeDataService {
  Stream<SensorModel> dataStream;

  void closeDataStream();
  void update(SensorModel newValues);
  void start();
  void stop();
  bool isRunning;
  List<String> currentValues;
}
