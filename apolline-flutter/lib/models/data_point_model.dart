import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/utils/position.dart';

// Authors BARRY Issagha, GDISSA Ramy
//Unité
class Units {
  static const String CONCENTRATION_UG_M3 = "µg/m3";
  static const String CONCENTRATION_ABOVE = "#/0.1L";
  static const String PERCENTAGE = "%";
  static const String TEMPERATURE_CELSIUS = "°C";
  static const String TEMPERATURE_KELVIN = "°K";
}


///
/// This class represents data reported by a sensor.
///
class DataPointModel {
  static const int SENSOR_DATE = 0;
  static const int SENSOR_PM_1 = 1;
  static const int SENSOR_PM_2_5 = 2;
  static const int SENSOR_PM_10 = 3;
  static const int SENSOR_TEMP = 17;
  static const int SENSOR_HUMI = 18;
  static const int SENSOR_VOLT = 19;
  static const int SENSOR_PM_ABOVE_0_3 = 4;
  static const int SENSOR_PM_ABOVE_0_5 = 5;
  static const int SENSOR_PM_ABOVE_1 = 6;
  static const int SENSOR_PM_ABOVE_2_5 = 7;
  static const int SENSOR_PM_ABOVE_5 = 8;
  static const int SENSOR_PM_ABOVE_10 = 9;
  static const int SENSOR_LATITUDE = 10;
  static const int SENSOR_LONGITUDE = 11;
  static const int SENSOR_GPS_SATELLITES_COUNT = 14;


  String sensorName;
  int _date;
  int id;
  Position position;

  /* Values received, parsed through a comma-separated string */
  List<String> values = [];

  DataPointModel({this.values, this.sensorName, this.position}) {
    this._date = DateTime.now().millisecondsSinceEpoch;
  }

  DataPointModel.bdd({this.id, this.values, this.sensorName, this.position, date}) {
    this._date = date;
  }

  ///
  /// return the temperature
  double get temperature {
    return double.parse(this.values[SENSOR_TEMP]);
  }

  ///
  ///return the temperature in kelvin.
  double get temperatureK {
    return double.parse(this.values[SENSOR_TEMP]) + 273.15;
  }

  ///
  ///return the pm 1 value
  double get pm1value {
    return double.parse(this.values[SENSOR_PM_1]);
  }

  ///
  ///return the pm 25 value
  double get pm25value {
    return double.parse(this.values[SENSOR_PM_2_5]);
  }

  ///
  ///return the pm 10 value
  double get pm10value {
    return double.parse(this.values[SENSOR_PM_10]);
  }

  ///
  ///return the pm above 0.3 value
  double get pmAbove03value {
    return double.parse(this.values[SENSOR_PM_ABOVE_0_3]);
  }

  ///
  ///return the pm above 0.5 value
  double get pmAbove05value {
    return double.parse(this.values[SENSOR_PM_ABOVE_0_5]);
  }

  ///
  ///return the pm above 1 value
  double get pmAbove1value {
    return double.parse(this.values[SENSOR_PM_ABOVE_1]);
  }

  ///
  ///return the pm above 2.5 value
  double get pmAbove25value {
    return double.parse(this.values[SENSOR_PM_ABOVE_2_5]);
  }

  ///
  ///return the pm above 5 value
  double get pmAbove5value {
    return double.parse(this.values[SENSOR_PM_ABOVE_5]);
  }

  ///
  ///return the pm above 10 value
  double get pmAbove10value {
    return double.parse(this.values[SENSOR_PM_ABOVE_10]);
  }

  ///
  /// return the humidity (not compensated)
  double get humidity {
    return double.parse(this.values[SENSOR_HUMI]);
  }

  ///
  ///return the humidity compensated.
  double get humidityC {
    var divisor = (1.0546 - 0.00216 * (this.temperatureK - 273.15)) * 10;
    return double.parse(this.values[SENSOR_HUMI]) / divisor;
  }

  ///
  ///return the date
  int get date {
    return this._date;
  }

  ///
  ///add one row for one properties.
  String addNestedData(String propertie, String value, String unit) {
    var provider = this.position?.provider ?? "no";
    var geohash = this.position?.geohash ?? "no";
    var transport = this.position?.transport ?? "no";
    return "$propertie,uuid=${BlueSensorAttributes.dustSensorServiceUUID}," +
        "device=$sensorName,provider=$provider,geohash=$geohash,transport=$transport," +
        "unit=$unit value=$value ${_date * 1000000}";
  }

  ///
  ///Format data to write into influxdb.
  String fmtToInfluxData() {
    var pm1 = addNestedData("pm.01.value", this.values[SENSOR_PM_1], Units.CONCENTRATION_UG_M3);
    var pm25 = addNestedData("pm.2_5.value", this.values[SENSOR_PM_2_5], Units.CONCENTRATION_UG_M3);
    var pm10 = addNestedData("pm.10.value", this.values[SENSOR_PM_10], Units.CONCENTRATION_UG_M3);
    var pm03ab = addNestedData("pm.0_3.above", this.values[SENSOR_PM_ABOVE_0_3], Units.CONCENTRATION_ABOVE);
    var pm05ab = addNestedData("pm.0_5.above", this.values[SENSOR_PM_ABOVE_0_5], Units.CONCENTRATION_ABOVE);
    var pm1ab = addNestedData("pm.1.above", this.values[SENSOR_PM_ABOVE_1], Units.CONCENTRATION_ABOVE);
    var pm25ab = addNestedData("pm.2_5.above", this.values[SENSOR_PM_ABOVE_2_5], Units.CONCENTRATION_ABOVE);
    var pm5ab = addNestedData("pm.5.above", this.values[SENSOR_PM_ABOVE_5], Units.CONCENTRATION_ABOVE);
    var pm10ab = addNestedData("pm.10.above", this.values[SENSOR_PM_ABOVE_10], Units.CONCENTRATION_ABOVE);
    var tmpC = addNestedData("temperature.c", this.values[SENSOR_TEMP], Units.TEMPERATURE_CELSIUS);
    var tmpK = addNestedData("temperature.k", this.temperatureK.toString(), Units.TEMPERATURE_KELVIN);
    var humi = addNestedData("humidity", this.values[SENSOR_HUMI], Units.PERCENTAGE);
    var humiC = addNestedData("humidity.compensated", this.humidityC.toString(), Units.PERCENTAGE);

    return "$pm1\n$pm25\n$pm10\n$pm03ab\n$pm05ab\n$pm1ab\n$pm25ab\n$pm5ab\n$pm10ab\n$tmpC\n$tmpK\n$humi\n$humiC";
  }

  ///Format data to write many sensorData into influxdb.
  static String sensorsFmtToInfluxData(List<DataPointModel> lastData) {
    var result = "";
    for(var i = 0; i < lastData.length; i++ ) {
      result += "${lastData[i].fmtToInfluxData()}\n";
    }
    return result;
  }

  Map<String, dynamic> toJSON() {
    var json = Map<String, dynamic>();
    json["deviceName"] = sensorName;
    json["uuid"] = BlueSensorAttributes.dustSensorServiceUUID;
    json["provider"] = this.position?.provider ?? "no";
    json["geohash"] = this.position?.geohash ?? "no";
    json["transport"] = this.position?.transport ?? "no";
    json["date"] = this._date;
    json["value"] = this.values.join('|');
    return json;
  }

  // ignore: non_constant_identifier_names
  // create object from Json
  DataPointModel.fromJson(Map<String, dynamic> json)
      : this.bdd(
            id: json['id'],
            values: json['value'].split('|'),
            sensorName: json['deviceName'],
            position: Position(geohash: json['geohash'], provider: json['provider'], transport: json['transport']),
            date: json['date']);
}
