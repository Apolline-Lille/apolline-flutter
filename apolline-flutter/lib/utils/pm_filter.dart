import 'package:flutter/cupertino.dart';


///
/// PMFilter allows users to select which particulate matters category to
/// display on the map.
///
/// Each filter has a label and its index in the data row.
///
/// For example, with the following received data:
///   > 2021_9_1_14_1_24;2;4;5;373;147;59;0;0;0;109.349998;0.000000;0.00;3.02
/// PM_1 value is 2 (index = 1), PM_2_5 value is 4 (index = 2) etc.
///
enum PMFilter {
  PM_1,
  PM_2_5,
  PM_10,
  PM_ABOVE_0_3,
  PM_ABOVE_0_5,
  PM_ABOVE_1,
  PM_ABOVE_2_5,
  PM_ABOVE_5,
  PM_ABOVE_10
}

class PMFilterValues {
  final String label;
  final int dataRowIndex;
  PMFilterValues({@required this.label, @required this.dataRowIndex});
}

extension PMFilterUtils on PMFilter {
  static final Map<PMFilter, PMFilterValues> _values = {
    PMFilter.PM_1: PMFilterValues(label: "PM_1", dataRowIndex: 1),
    PMFilter.PM_2_5: PMFilterValues(label: "PM_2_5", dataRowIndex: 2),
    PMFilter.PM_10: PMFilterValues(label: "PM_10", dataRowIndex: 3),
    PMFilter.PM_ABOVE_0_3: PMFilterValues(label: "PM_ABOVE_0_3", dataRowIndex: 4),
    PMFilter.PM_ABOVE_0_5: PMFilterValues(label: "PM_ABOVE_0_5", dataRowIndex: 5),
    PMFilter.PM_ABOVE_1: PMFilterValues(label: "PM_ABOVE_1", dataRowIndex: 6),
    PMFilter.PM_ABOVE_2_5: PMFilterValues(label: "PM_ABOVE_2_5", dataRowIndex: 7),
    PMFilter.PM_ABOVE_5: PMFilterValues(label: "PM_ABOVE_5", dataRowIndex: 8),
    PMFilter.PM_ABOVE_10: PMFilterValues(label: "PM_ABOVE_10", dataRowIndex: 9)
  };

  int getRowIndex () {
    return PMFilterUtils._values[this].dataRowIndex;
  }

  static List<String> getLabels () {
    return PMFilter.values.map((filter) => PMFilterUtils._values[filter].label).toList();
  }
}