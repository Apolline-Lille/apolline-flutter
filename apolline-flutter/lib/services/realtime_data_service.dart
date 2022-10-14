import 'package:apollineflutter/models/data_point_model.dart';

/// abstract class
/// realtimedataService a service to stream data points
abstract class RealtimeDataService {
  late Stream<DataPointModel> dataStream;

  /// close Stream
  void closeDataStream();
  /// update Stream when we recieve a new model
  void update(DataPointModel newValues);
  /// start recieve model
  void start();
  /// stop recieve model
  void stop();
  late bool isRunning;
  late List<String> currentValues;
}
