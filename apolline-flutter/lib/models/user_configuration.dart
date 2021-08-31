import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/utils/time_filter.dart';


///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  TimeFilter _timeFilter ;
  ///index pm in data point.
  int _pmIndex;
  ///time filter json key
  static const String TIME_FILTER_KEY = "timeFilterValue";

  ///
  ///Constructor
  UserConfiguration({timeFilter: TimeFilter.MAP_SYNC_1_MIN, pmIndex: DataPointModel.SENSOR_PM_2_5}) {
    this._timeFilter = timeFilter;
    this._pmIndex = pmIndex;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map json) {
    this._timeFilter = TimeFilter.values[json[UserConfiguration.TIME_FILTER_KEY]];
    this._pmIndex = json['pmIndex'];
  }

  ///
  ///formate class to json.
  Map<String, dynamic> toJson() {
    return {
      UserConfiguration.TIME_FILTER_KEY: this.timeFilter.index,
      "pmIndex": this._pmIndex
    };
  }

  ///
  ///getteur map
  TimeFilter get timeFilter {
    return this._timeFilter;
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
  set timeFilter(TimeFilter filter) {
    this._timeFilter = filter;
  }

}