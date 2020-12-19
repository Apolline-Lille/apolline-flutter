import 'package:apollineflutter/models/sensor_device.dart';
import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/utils/position.dart';

class Units {
  static const String CONCENTRATION_UG_M3 = "µg/m3";
  static const String CONCENTRATION_ABOVE = "#/0.1L";
  static const String PERCENTAGE          = "%";
  static const String TEMPERATURE_CELSIUS = "°C";
  static const String TEMPERATURE_KELVIN  = "°K";
}
class SensorModel {
  static const int SENSOR_DATE = 0;
  static const int SENSOR_PM_1 = 1;
  static const int SENSOR_PM_2_5 = 2;
  static const int SENSOR_PM_10 = 3;
  static const int SENSOR_TEMP = 17;
  static const int SENSOR_HUMI = 18;
  static const int SENSOR_VOLT = 19;
  SensorDevice device;
  int _date;
  Position position;

  /* Values received, parsed through a comma-separated string */
  List<String> values = [];

  ///
  ///constructor of senorModel.
  SensorModel({this.values, this.device, this.position}) {
    this._date = DateTime.now().microsecondsSinceEpoch;
  }

  ///
  ///return the temperature in kelvin.
  double get temperatureK {
    return double.parse(this.values[SENSOR_TEMP]) + 273.15;
  }

  ///
  ///return the humidity compensated.
  double get humidityC {
    var divisor = (1.0546 - 0.00216 * (this.temperatureK - 273.15)) * 10;
    return double.parse(this.values[SENSOR_HUMI])/divisor;
  }

  ///
  ///add one row for one properties.
  String addNestedData(String propertie, String value, String unit) {
    var provider  = this.position?.provider ?? "no";
    var geohash   = this.position?.geohash ?? "no";
    var transport = this.position?.transport ?? "no";
    var deviceName  = device?.deviceName ?? "Apolline00";
    return "$propertie,uuid=${BlueSensorAttributes.DustSensorServiceUUID},"+
           "device=$deviceName,provider=$provider,geohash=$geohash,transport=$transport,"+
           "unit=$unit value=$value ${_date*1000000}";
  }

  ///
  ///Format data for write into influxdb.
  String fmtToInfluxData() {
    var pm1  = addNestedData("pm.01.value", this.values[SENSOR_PM_1], Units.CONCENTRATION_UG_M3);
    var pm25 = addNestedData("pm.2_5.value", this.values[SENSOR_PM_2_5], Units.CONCENTRATION_UG_M3);
    var pm10 = addNestedData("pm.10.value", this.values[SENSOR_PM_10], Units.CONCENTRATION_UG_M3);
    var tmpC = addNestedData("temperature.c", this.values[SENSOR_TEMP], Units.TEMPERATURE_CELSIUS);
    var tmpK = addNestedData("temperature.k", this.temperatureK.toString(), Units.TEMPERATURE_KELVIN);
    var humi = addNestedData("humidity", this.values[SENSOR_HUMI], Units.PERCENTAGE);
    var humiC = addNestedData("humidity.compensated", this.humidityC.toString(), Units.PERCENTAGE);
    return "$pm1\n$pm25\n$pm10\n$tmpC\n$tmpK\n$humi\n$humiC";
  }
}