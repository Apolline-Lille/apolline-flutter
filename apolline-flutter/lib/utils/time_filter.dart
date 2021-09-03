import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';


///
/// TimeFilter allows users to select all data points gathered before a given date.
/// Each filter has a label and a method to obtain corresponding minutes count.
///
enum TimeFilter {
  LAST_MIN,
  LAST_5_MIN,
  LAST_15_MIN,
  LAST_30_MIN,
  LAST_HOUR,
  LAST_3_HOURS,
  LAST_6_HOURS,
  LAST_12_HOURS,
  LAST_24_HOURS,
  TODAY,
  THIS_WEEK,
}

class _TimeFilterValues {
  String label;
  int Function() toMinutes;
  _TimeFilterValues({@required this.label, @required this.toMinutes});
}

extension TimeFilterUtils on TimeFilter {
  static final Map<TimeFilter, _TimeFilterValues> _values = {
    TimeFilter.LAST_MIN: _TimeFilterValues(label: "mapView.timeFilters.lastMin", toMinutes: () => 1),
    TimeFilter.LAST_5_MIN: _TimeFilterValues(label: "mapView.timeFilters.last5Mins", toMinutes: () => 5),
    TimeFilter.LAST_15_MIN: _TimeFilterValues(label: "mapView.timeFilters.last15Mins", toMinutes: () => 15),
    TimeFilter.LAST_30_MIN: _TimeFilterValues(label: "mapView.timeFilters.last30Mins", toMinutes: () => 30),
    TimeFilter.LAST_HOUR: _TimeFilterValues(label: "mapView.timeFilters.lastHour", toMinutes: () => 60),
    TimeFilter.LAST_3_HOURS: _TimeFilterValues(label: "mapView.timeFilters.last3Hours", toMinutes: () => 180),
    TimeFilter.LAST_6_HOURS: _TimeFilterValues(label: "mapView.timeFilters.last6Hours", toMinutes: () => 360),
    TimeFilter.LAST_12_HOURS: _TimeFilterValues(label: "mapView.timeFilters.last12Hours", toMinutes: () => 720),
    TimeFilter.LAST_24_HOURS: _TimeFilterValues(label: "mapView.timeFilters.last24Hours", toMinutes: () => 1440),
    TimeFilter.TODAY: _TimeFilterValues(label: "mapView.timeFilters.today", toMinutes: () {
        DateTime now = DateTime.now();
        return now.hour*60 + now.minute;
      }),
    TimeFilter.THIS_WEEK: _TimeFilterValues(label: "mapView.timeFilters.thisWeek",
      toMinutes: () {
        DateTime now = DateTime.now();
        int minutesForToday = now.hour*60 + now.minute;
        return (now.weekday - 1) * 24 * 60 + minutesForToday;
      })
  };


  int toMinutes () {
    if (TimeFilterUtils._values[this] == null)
      throw RangeError("This TimeFilter has no value.");
    return TimeFilterUtils._values[this].toMinutes();
  }

  static List<String> getLabels () {
    return TimeFilter.values.map((filter) => TimeFilterUtils._values[filter].label.tr()).toList();
  }
}