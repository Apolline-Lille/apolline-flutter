import 'dart:convert';

import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEvent.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';
import 'package:apollineflutter/utils/time_filter.dart';


///Author (Issagha BARRY)
///User configuration in ui
class UserConfiguration {
  
  ///variable to retrieve data up to x minute
  late TimeFilter _timeFilter;
  ///which PM data to display
  late PMFilter _pmFilter;
  ///pm size concentration limits
  late Map<PMFilter, List<int>> _thresholdsValues;
  ///pm concentration alerts
  late List<bool> _shouldSendThresholdNotifications;
  ///exposure notifications time interval
  late Duration exposureNotificationsTimeInterval;
  ///sensor events
  Map<String, List<SensorEvent>>? _sensorEvents;

  ///Json keys
  static const String TIME_FILTER_KEY = "timeFilterValue";
  static const String PM_FILTER_KEY = "pmFilterValue";
  static const String THRESHOLDS_KEY = "thresholdsValue";
  static const String ALERTS_KEY = "thresholdsAlertsValue";
  static const String NOTIFICATIONS_KEY = "notificationsValue";
  static const String SENSOR_EVENTS_KEY = "sensorEventsKey";


  ///
  /// Constructor with default parameters.
  /// This constructor is used when user hasn't registered any custom setting
  /// (e.g. alert notification frequency); when user registered settings, you'd
  /// better user UserConfiguration.fromJson constructor.
  ///
  UserConfiguration() {
    this._timeFilter = TimeFilter.LAST_MIN;
    this._pmFilter = PMFilter.PM_2_5;
    this.exposureNotificationsTimeInterval = const Duration(minutes: 5);
    this._shouldSendThresholdNotifications = [true, true];
    this._sensorEvents = {};
    this._thresholdsValues = PMFilterUtils.getThresholds();
  }

  ///
  ///Constructor from json
  UserConfiguration.fromJson(Map jsonMap) {
    this._timeFilter = TimeFilter.values[jsonMap[UserConfiguration.TIME_FILTER_KEY]];
    this._pmFilter = PMFilter.values[jsonMap[UserConfiguration.PM_FILTER_KEY]];
    this._shouldSendThresholdNotifications = jsonMap[UserConfiguration.ALERTS_KEY].cast<bool>();

    Map<String, dynamic> eventValues = jsonMap[UserConfiguration.SENSOR_EVENTS_KEY];
    Map<String, List<SensorEvent>> events = {};
    eventValues.forEach((key, value) {
      print(key);
      List<SensorEvent> localEvents = [];
      (value as List<dynamic>).forEach((element) {
        localEvents.add(SensorEvent.fromJson(element));
      });
      events.putIfAbsent(key, () => localEvents);
    });
    this._sensorEvents = events;

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
      UserConfiguration.NOTIFICATIONS_KEY: this.exposureNotificationsTimeInterval.inMilliseconds,
      UserConfiguration.SENSOR_EVENTS_KEY: this._sensorEvents
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
    return this._thresholdsValues[filter]!;
  }

  void updatePMThreshold (PMFilter filter, int thresholdIndex, int newValue) {
    this._thresholdsValues[filter]![thresholdIndex] = newValue;
  }

  List<int> getCurrentThresholds () {
    return this._thresholdsValues[this.pmFilter]!;
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

  List<SensorEvent> getSensorEvents(String deviceName) {
    return this._sensorEvents![deviceName]!;
  }
  void addSensorEvent (String deviceName, SensorEventType event) {
    if (this._sensorEvents![deviceName] == null) this._sensorEvents![deviceName] = [];
    this._sensorEvents![deviceName]!.add( SensorEvent(event) );
  }
  void clearSensorEvents (String deviceName) {
    DateTime now = DateTime.now();
    print("Removing sensor events older than one week.");
    this._sensorEvents![deviceName] =
        this._sensorEvents![deviceName]!
            .where((element) => now.difference(element.time) < Duration(days: 7)).toList();
  }
}