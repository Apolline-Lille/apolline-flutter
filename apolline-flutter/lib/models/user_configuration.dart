import 'dart:convert';

import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEvent.dart';
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
  ///pm concentration alerts
  List<bool> _shouldSendThresholdNotifications;
  ///exposure notifications time interval
  Duration exposureNotificationsTimeInterval;
  ///sensor events
  List<SensorEvent> _sensorEvents;

  ///Json keys
  static const String TIME_FILTER_KEY = "timeFilterValue";
  static const String PM_FILTER_KEY = "pmFilterValue";
  static const String THRESHOLDS_KEY = "thresholdsValue";
  static const String ALERTS_KEY = "thresholdsAlertsValue";
  static const String NOTIFICATIONS_KEY = "notificationsValue";
  static const String SENSOR_EVENTS_KEY = "sensorEventsKey";

  ///
  ///Constructor
  UserConfiguration({timeFilter: TimeFilter.LAST_MIN,
    pmFilter: PMFilter.PM_2_5,
    Map<PMFilter, int> thresholds,
    List<bool> alerts,
    Duration notificationsInterval: const Duration(minutes: 5),
    List<SensorEvent> sensorEvents
  }) {
    this._timeFilter = timeFilter;
    this._pmFilter = pmFilter;
    this.exposureNotificationsTimeInterval = notificationsInterval;
    this._shouldSendThresholdNotifications = alerts == null || alerts.length == 0
        ? [true, true]
        : alerts;
    this._thresholdsValues = thresholds == null || thresholds.keys.length == 0
        ? PMFilterUtils.getThresholds()
        : thresholds;
    this._sensorEvents = sensorEvents == null || _sensorEvents.length == 0
      ? []
      : sensorEvents;
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map jsonMap) {
    this._timeFilter = TimeFilter.values[jsonMap[UserConfiguration.TIME_FILTER_KEY]];
    this._pmFilter = PMFilter.values[jsonMap[UserConfiguration.PM_FILTER_KEY]];
    this._shouldSendThresholdNotifications = jsonMap[UserConfiguration.ALERTS_KEY].cast<bool>();
    this._sensorEvents = jsonMap[UserConfiguration.SENSOR_EVENTS_KEY].cast<SensorEvent>();

    Map<String, dynamic> values = json.decode(jsonMap[UserConfiguration.THRESHOLDS_KEY]);
    Map<PMFilter, List<int>> thresholds = Map();
    values.forEach((key, value) {
      thresholds.putIfAbsent(PMFilter.values[int.parse(key)], () => value.cast<int>());
    });

    this._thresholdsValues = thresholds;
    this.exposureNotificationsTimeInterval = Duration(milliseconds: jsonMap[UserConfiguration.NOTIFICATIONS_KEY]);
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
      UserConfiguration.THRESHOLDS_KEY: json.encode(jsonValues),
      UserConfiguration.ALERTS_KEY: this._shouldSendThresholdNotifications,
      UserConfiguration.NOTIFICATIONS_KEY: this.exposureNotificationsTimeInterval.inMilliseconds
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

  void updatePMThreshold (PMFilter filter, int thresholdIndex, int newValue) {
    this._thresholdsValues[filter][thresholdIndex] = newValue;
  }

  List<int> getCurrentThresholds () {
    return this._thresholdsValues[this.pmFilter];
  }

  bool get showWarningNotifications {
    return this._shouldSendThresholdNotifications[0];
  }
  set showWarningNotifications (bool value) {
    this._shouldSendThresholdNotifications[0] = value;
  }

  bool get showDangerNotifications {
    return this._shouldSendThresholdNotifications[1];
  }
  set showDangerNotifications (bool value) {
    this._shouldSendThresholdNotifications[1] = value;
  }

  List<SensorEvent> getSensorEvents () {
    return this._sensorEvents;
  }
}