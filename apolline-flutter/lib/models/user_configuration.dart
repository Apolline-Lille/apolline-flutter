import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/time_filter.dart';


///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  TimeFilter _timeFilter;
  ///which PM data to display
  PMFilter _pmFilter;

  ///Json keys
  static const String TIME_FILTER_KEY = "timeFilterValue";
  static const String PM_FILTER_KEY = "pmFilterValue";

  ///
  ///Constructor
  UserConfiguration({timeFilter: TimeFilter.LAST_MIN, pmFilter: DataPointModel.SENSOR_PM_2_5}) {
    this._timeFilter = timeFilter;
    this._pmFilter = pmFilter;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map json) {
    this._timeFilter = TimeFilter.values[json[UserConfiguration.TIME_FILTER_KEY]];
    this._pmFilter = PMFilter.values[json[UserConfiguration.PM_FILTER_KEY]];
  }

  ///
  ///formate class to json.
  Map<String, dynamic> toJson() {
    return {
      UserConfiguration.TIME_FILTER_KEY: this.timeFilter.index,
      UserConfiguration.PM_FILTER_KEY: this._pmFilter.index
    };
  }

  ///
  ///getteur map
  TimeFilter get timeFilter {
    return this._timeFilter;
  }

  ///
  ///get pm filter
  PMFilter get pmFilter {
    return this._pmFilter;
  }

  ///
  ///setteur
  set pmFilter(PMFilter filter) {
    this._pmFilter = filter;
  }

  ///
  ///Setteur
  set timeFilter(TimeFilter filter) {
    this._timeFilter = filter;
  }
}