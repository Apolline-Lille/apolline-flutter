import 'package:flutter/foundation.dart';

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

class TimeFilterValues {
  String label;
  int Function() toMinutes;
  TimeFilterValues({@required this.label, @required this.toMinutes});
}

extension TimeFilterUtils on TimeFilter {
  static final Map<TimeFilter, TimeFilterValues> _values = {
    TimeFilter.LAST_MIN: TimeFilterValues(label: "last minute", toMinutes: () => 1),
    TimeFilter.LAST_5_MIN: TimeFilterValues(label: "last 5 minutes", toMinutes: () => 5),
    TimeFilter.LAST_15_MIN: TimeFilterValues(label: "last 15 minutes", toMinutes: () => 15),
    TimeFilter.LAST_30_MIN: TimeFilterValues(label: "last 30 minutes", toMinutes: () => 30),
    TimeFilter.LAST_HOUR: TimeFilterValues(label: "last 1 hour", toMinutes: () => 60),
    TimeFilter.LAST_3_HOURS: TimeFilterValues(label: "last 3 hours", toMinutes: () => 180),
    TimeFilter.LAST_6_HOURS: TimeFilterValues(label: "last 6 hours", toMinutes: () => 360),
    TimeFilter.LAST_12_HOURS: TimeFilterValues(label: "last 12 hours", toMinutes: () => 720),
    TimeFilter.LAST_24_HOURS: TimeFilterValues(label: "last 24 hours", toMinutes: () => 1440),
    TimeFilter.TODAY: TimeFilterValues(label: "today", toMinutes: () {
        DateTime now = DateTime.now();
        return now.hour*60 + now.minute;
      }),
    TimeFilter.THIS_WEEK: TimeFilterValues(label: "This week",
      toMinutes: () {
        DateTime now = DateTime.now();
        int minutesForToday = now.hour*60 + now.minute;
        return (now.weekday - 1) * 24 * 60 + minutesForToday;
      })
  };


  int toMinutes () {
    return TimeFilterUtils._values[this].toMinutes();
  }

  static List<String> getLabels () {
    return TimeFilter.values.map((filter) => TimeFilterUtils._values[filter].label).toList();
  }
}