import 'package:apollineflutter/models/data_point_model.dart';


/// Sensore Collection used to make last data in collection 
class SensorCollection {
  // to stock lastData
  List<DataPointModel> lastData;

  int get length {
    return this.lastData.length;
  }

  /// Conctructor
  SensorCollection() {
    this.lastData = [];
  }
  
  /// Add a sensor model to lastData collection
  void addModel(DataPointModel model) {
    this.lastData.add(model);
  }

  /// Clean collection
  void clear() {
    this.lastData.clear();
  }
  
  /// make data in send format
  String fmtToInfluxData() {
    var result = "";

    for(var i = 0; i < this.lastData.length; i++ ) {
      result += "${this.lastData[i].fmtToInfluxData()}\n";
    }
    return result;
  }

}