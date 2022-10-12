import 'dart:async';

import 'realtime_data_service.dart';
import 'package:apollineflutter/models/data_point_model.dart';

/// RealtimeDataServiceImpl to implement method for the service
class RealtimeDataServiceImpl extends RealtimeDataService {
  late StreamController<DataPointModel>? _streamController;
  List<String> values = [];
  // ignore: non_constant_identifier_names
  bool is_running = true;

  bool get isRunning {
    bool result = is_running == true;
    return result;
  }

  List<String> get currentValues {
    return values;
  }

  @override
  void start() {
    if (is_running == false) {
      is_running = true;
    }
  }

  @override
  void stop() {
    if (is_running == true) {
      is_running = false;
    }
  }

  @override
  Stream<DataPointModel> get dataStream {
    if (_streamController == null) {
      _streamController = StreamController.broadcast(
        onListen: start,
        onCancel: stop,
      );
    }
    return _streamController!.stream;
  }

  @override
  void closeDataStream() {
    _streamController!.close();
  }

  @override
  void update(DataPointModel newValues) {
    // values = newValues;
    if (_streamController != null && is_running == true) {
      values = newValues.values;
      _streamController!.add(newValues);
    }
  }
}
