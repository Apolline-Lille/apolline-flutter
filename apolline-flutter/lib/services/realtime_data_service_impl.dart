import 'dart:async';

import 'realtime_data_service.dart';

class RealtimeDataServiceImpl extends RealtimeDataService {
  StreamController<SensorModels> _streamController;
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
  Stream<SensorModels> get dataStream {
    if (_streamController == null) {
      _streamController = StreamController.broadcast(
        onListen: start,
        onCancel: stop,
      );
    }
    return _streamController.stream;
  }

  @override
  void closeDataStream() {
    _streamController.close();
  }

  @override
  void update(List<String> newValues) {
    // values = newValues;
    if (_streamController != null && is_running == true) {
      values = newValues;
      _streamController.add(SensorModels(newValues));
    }
  }
}
