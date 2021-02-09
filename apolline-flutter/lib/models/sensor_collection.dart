import 'package:apollineflutter/models/sensormodel.dart';

class SensorCollection {

  List<SensorModel> lastData;

  int get length {
    return this.lastData.length;
  }

  SensorCollection() {
    this.lastData = [];
  }

  void addModel(SensorModel model) {
    this.lastData.add(model);
  }

  void clear() {
    this.lastData.clear();
  }

  String fmtToInfluxData() {
    var result = "";

    for(var i = 0; i < this.lastData.length; i++ ) {
      result += "${this.lastData[i].fmtToInfluxData()}\n";
    }
    return result;
  }

}