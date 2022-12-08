import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/utils/position/position.dart';
import 'package:apollineflutter/utils/position/position_provider.dart';

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
  // sensor data frame header
  // AAAA_MM_JJ_hh_mm_ss;PM1.0;PM2.5;PM10(ug/m3);Above PM0.3;PM0.5;PM1;PM2.5;PM5;PM10(ug/m3);Latitude;Longitude;Altitude;speed(km/h);satellites count;TemperatureDPS310(°C);PressureDPS310(Pascal);TemperatureHDC1080(°C);HumidityHDC1080(%);battery level;Adjusted temperature(°C);Adjusted humidity(%);TemperatureAM2320(°C);HumidityAM2320(%)
  static const int SENSOR_DATE = 0;
  static const int SENSOR_PM_1 = 1;
  static const int SENSOR_PM_2_5 = 2;
  static const int SENSOR_PM_10 = 3;
  static const int SENSOR_PM_ABOVE_0_3 = 4;
  static const int SENSOR_PM_ABOVE_0_5 = 5;
  static const int SENSOR_PM_ABOVE_1 = 6;
  static const int SENSOR_PM_ABOVE_2_5 = 7;
  static const int SENSOR_PM_ABOVE_5 = 8;
  static const int SENSOR_PM_ABOVE_10 = 9;
  static const int SENSOR_LATITUDE = 10;
  static const int SENSOR_LONGITUDE = 11;
  static const int SENSOR_ALTITUDE = 12;
  static const int SENSOR_SPEED = 13;
  static const int SENSOR_GPS_SATELLITES_COUNT = 14;
  static const int SENSOR_TEMP_DPS310 = 15;
  static const int SENSOR_HUMI_DPS310 = 16;
  static const int SENSOR_TEMP = 17;
  static const int SENSOR_HUMI = 18;
  static const int SENSOR_VOLT = 19;
  static const int SENSOR_TEMP_ADJUSTED = 20;
  static const int SENSOR_HUMI_ADJUSTED = 21;
  static const int SENSOR_TEMP_AM2320 = 22;
  static const int SENSOR_HUMI_AM2320 = 23;


  String sensorName;
  late int date;
  int id;
  Position? position;

  /* Values received, parsed through a comma-separated string */
  List<String> values = [];

  DataPointModel({
    required this.id,
    required this.values,
    required this.sensorName,
    required this.position
  }) {
    this.date = DateTime.now().millisecondsSinceEpoch;
  }

  DataPointModel.bdd({
    required this.id,
    required this.values,
    required this.sensorName,
    required this.position,
    required this.date
  });

  ///
  ///return the temperature in kelvin.
  double get temperatureK {
    return double.parse(this.values[SENSOR_TEMP]) + 273.15;
  }

  ///
  ///return the pm 25 value
  double get pm25value {
    return double.parse(this.values[SENSOR_PM_2_5]);
  }

  ///
  ///return the humidity compensated.
  double get humidityC {
    var divisor = (1.0546 - 0.00216 * (this.temperatureK - 273.15)) * 10;
    return double.parse(this.values[SENSOR_HUMI]) / divisor;
  }

  ///
  ///add one row for one properties.
  String addNestedData(String propertie, String value, String unit) {
    var provider = this.position?.provider.value;
    var transport = this.position?.transport ?? "no";
    var cleanedValue = value.replaceAll('\n', '');
    cleanedValue = cleanedValue.replaceAll('\r', '');
    cleanedValue = cleanedValue.replaceAll(' ', '');
    return "$propertie,uuid=${BlueSensorAttributes.dustSensorServiceUUID}," +
        "device=$sensorName,provider=$provider,${this.position?.toInfluxDbFormat()},transport=$transport," +
        "unit=$unit value=$cleanedValue ${date * 1000000}";
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

    // Temperatures
    var tmpC = addNestedData("temperature.c", this.values[SENSOR_TEMP], Units.TEMPERATURE_CELSIUS);
    var tmpK = addNestedData("temperature.k", this.temperatureK.toString(), Units.TEMPERATURE_KELVIN);
    var tmpDps310 = addNestedData("temperature_dps310.c", this.values[SENSOR_TEMP_DPS310], Units.TEMPERATURE_CELSIUS);
    var tmpAdj = addNestedData("temperature_adjusted.c", this.values[SENSOR_TEMP_ADJUSTED], Units.TEMPERATURE_CELSIUS);
    // var tmpAm2320 = addNestedData("temperature_am2320.c", this.values[SENSOR_TEMP_AM2320], Units.TEMPERATURE_CELSIUS);

    // Humidity
    var humi = addNestedData("humidity", this.values[SENSOR_HUMI], Units.PERCENTAGE);
    var humiC = addNestedData("humidity.compensated", this.humidityC.toString(), Units.PERCENTAGE);
    var humiDps310 = addNestedData("humidity_dps310", this.values[SENSOR_HUMI_DPS310], Units.PERCENTAGE);
    var humAdj = addNestedData("humidity_adjusted", this.values[SENSOR_HUMI_ADJUSTED], Units.PERCENTAGE);
    // var humAdj2320 = addNestedData("humidity_am2320", this.values[SENSOR_HUMI_AM2320], Units.PERCENTAGE);

    return "$pm1\n$pm25\n$pm10\n$pm03ab\n$pm05ab\n$pm1ab\n$pm25ab\n$pm5ab\n$pm10ab\n$tmpC\n$tmpK\n$tmpDps310\n$tmpAdj\n$humi\n$humiC\n$humiDps310\n$humAdj";
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
    json["provider"] = this.position?.provider.value;
    json["geohash"] = this.position?.geohash ?? "no";
    json["transport"] = this.position?.transport ?? "no";
    json["date"] = this.date;
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
            position: Position(geohash: json['geohash'], provider: PositionProviderUtils.fromString(json['provider']), transport: json['transport']),
            date: json['date']);
}
