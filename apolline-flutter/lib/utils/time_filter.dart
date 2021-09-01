import 'package:flutter/foundation.dart';

enum TimeFilter {
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

class TimeFilterValues {
  String label;
  int Function() toMinutes;
  TimeFilterValues({@required this.label, @required this.toMinutes});
}

extension TimeFilterUtils on TimeFilter {
  static final Map<TimeFilter, TimeFilterValues> _values = {
    TimeFilter.MAP_SYNC_1_MIN: TimeFilterValues(label: "last minute", toMinutes: () => 1),
    TimeFilter.MAP_SYNC_5_MIN: TimeFilterValues(label: "last 5 minutes", toMinutes: () => 5),
    TimeFilter.MAP_SYNC_15_MIN: TimeFilterValues(label: "last 15 minutes", toMinutes: () => 15),
    TimeFilter.MAP_SYNC_30_MIN: TimeFilterValues(label: "last 30 minutes", toMinutes: () => 30),
    TimeFilter.MAP_SYNC_1_HOUR: TimeFilterValues(label: "last 1 hour", toMinutes: () => 60),
    TimeFilter.MAP_SYNC_3_HOUR: TimeFilterValues(label: "last 3 hours", toMinutes: () => 180),
    TimeFilter.MAP_SYNC_6_HOUR: TimeFilterValues(label: "last 6 hours", toMinutes: () => 360),
    TimeFilter.MAP_SYNC_12_HOUR: TimeFilterValues(label: "last 12 hours", toMinutes: () => 720),
    TimeFilter.MAP_SYNC_24_HOUR: TimeFilterValues(label: "last 24 hours", toMinutes: () => 1440),
    TimeFilter.MAP_SYNC_TODAY: TimeFilterValues(label: "today", toMinutes: () {
        DateTime now = DateTime.now();
        return now.hour*60 + now.minute;
      }),
    TimeFilter.MAP_SYNC_THIS_WEEK: TimeFilterValues(label: "This week",
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