import 'package:apollineflutter/models/data_point_model.dart';
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

class _PMFilterValues {
  final String label;
  final int dataRowIndex;
  _PMFilterValues({@required this.label, @required this.dataRowIndex});
}

extension PMFilterUtils on PMFilter {
  static final Map<PMFilter, _PMFilterValues> _values = {
    PMFilter.PM_1: _PMFilterValues(label: "PM_1", dataRowIndex: DataPointModel.SENSOR_PM_1),
    PMFilter.PM_2_5: _PMFilterValues(label: "PM_2_5", dataRowIndex: DataPointModel.SENSOR_PM_2_5),
    PMFilter.PM_10: _PMFilterValues(label: "PM_10", dataRowIndex: DataPointModel.SENSOR_PM_10),
    PMFilter.PM_ABOVE_0_3: _PMFilterValues(label: "PM_ABOVE_0_3", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_0_3),
    PMFilter.PM_ABOVE_0_5: _PMFilterValues(label: "PM_ABOVE_0_5", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_0_5),
    PMFilter.PM_ABOVE_1: _PMFilterValues(label: "PM_ABOVE_1", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_1),
    PMFilter.PM_ABOVE_2_5: _PMFilterValues(label: "PM_ABOVE_2_5", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_2_5),
    PMFilter.PM_ABOVE_5: _PMFilterValues(label: "PM_ABOVE_5", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_5),
    PMFilter.PM_ABOVE_10: _PMFilterValues(label: "PM_ABOVE_10", dataRowIndex: DataPointModel.SENSOR_PM_ABOVE_10)
  };


  int getRowIndex () {
    if (PMFilterUtils._values[this] == null)
      throw RangeError("This PMFilter has no associated row index.");
    return PMFilterUtils._values[this].dataRowIndex;
  }

  static List<String> getLabels () {
    return PMFilter.values.map((filter) => PMFilterUtils._values[filter].label).toList();
  }
}