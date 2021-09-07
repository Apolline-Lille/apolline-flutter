import 'dart:convert';

import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/time_filter.dart';


///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  TimeFilter _timeFilter;
  ///which PM data to display
  PMFilter _pmFilter;
  ///pm size concentration limits
  Map<PMFilter, List<int>> _thresholdsValues;

  ///Json keys
  static const String TIME_FILTER_KEY = "timeFilterValue";
  static const String PM_FILTER_KEY = "pmFilterValue";
  static const String THRESHOLDS_KEY = "thresholdsValue";

  ///
  ///Constructor
  UserConfiguration({timeFilter: TimeFilter.LAST_MIN, pmFilter: PMFilter.PM_2_5, Map<PMFilter, int> thresholds}) {
    this._timeFilter = timeFilter;
    this._pmFilter = pmFilter;
    this._thresholdsValues = thresholds == null || thresholds.keys.length == 0
        ? PMFilterUtils.getThresholds()
        : thresholds;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map jsonMap) {
    this._timeFilter = TimeFilter.values[jsonMap[UserConfiguration.TIME_FILTER_KEY]];
    this._pmFilter = PMFilter.values[jsonMap[UserConfiguration.PM_FILTER_KEY]];

    Map<String, dynamic> values = json.decode(jsonMap[UserConfiguration.THRESHOLDS_KEY]);
    Map<PMFilter, List<int>> thresholds = Map();
    values.forEach((key, value) {
      thresholds.putIfAbsent(PMFilter.values[int.parse(key)], () => value.cast<int>());
    });

    this._thresholdsValues = thresholds;
  }

  ///
  ///formate class to json.
  Map<String, dynamic> toJson() {
    var jsonValues = {};
    this._thresholdsValues.keys.forEach((element) {
      jsonValues[element.index.toString()] = this._thresholdsValues[element];
    });

    return {
      UserConfiguration.TIME_FILTER_KEY: this.timeFilter.index,
      UserConfiguration.PM_FILTER_KEY: this._pmFilter.index,
      UserConfiguration.THRESHOLDS_KEY: json.encode(jsonValues)
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

  List<int> getThresholds (PMFilter filter) {
    return this._thresholdsValues[filter];
  }
}