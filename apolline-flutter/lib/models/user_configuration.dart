import 'package:apollineflutter/models/data_point_model.dart';


///Author (Issagha BARRY)
///
enum MapFrequency {
  MAP_SYNC_1_MIN,
  MAP_SYNC_5_MIN,
  MAP_SYNC_15_MIN,
  MAP_SYNC_30_MIN,
  MAP_SYNC_1_HOUR,
  MAP_SYNC_3_HOUR,
  MAP_SYNC_6_HOUR,
  MAP_SYNC_12_HOUR,
  MAP_SYNC_24_HOUR,
  MAP_SYNC_TODAY,
  MAP_SYNC_THIS_WEEK,
}

///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  MapFrequency _mapSyncFrequency ;
  ///index pm in data point.
  int _pmIndex;

  ///
  ///Constructor
  UserConfiguration({mapSyncFrequency: MapFrequency.MAP_SYNC_1_MIN, pmIndex: DataPointModel.SENSOR_PM_2_5}) {
    this._mapSyncFrequency = mapSyncFrequency;
    this._pmIndex = pmIndex;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map json) {
    this._mapSyncFrequency = MapFrequency.values[json['mapSyncFreq']];
    this._pmIndex = json['pmIndex'];
  }

  ///
  ///formate class to json.
  Map<String, dynamic> toJson() {
    return {
      "mapSyncFreq": this.mapSyncFrequency.index,
      "pmIndex": this._pmIndex
    };
  }

  ///
  ///getteur map
  MapFrequency get mapSyncFrequency {
    return this._mapSyncFrequency;
  }

  ///
  ///gette index pm
  int get pmIndex {
    return this._pmIndex;
  }

  ///
  ///setteur
  set pmIndex(int index) {
    this._pmIndex = index;
  }

  ///
  ///Setteur
  set mapSyncFrequency(MapFrequency frequency) {
    this._mapSyncFrequency = frequency;
  }

}