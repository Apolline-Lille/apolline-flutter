class SensorModel
{
  static const int SENSOR_DATE = 0;
  static const int SENSOR_PM_1 = 1;
  static const int SENSOR_PM_2_5 = 2;
  static const int SENSOR_PM_10 = 3;
  static const int SENSOR_TEMP = 17;
  static const int SENSOR_VOLT = 19;

  /* Values received, parsed through a comma-separated string */
  List<String> values = [];

  SensorModel({
    this.values,
  });
}