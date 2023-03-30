import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/utils/position/position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasAM2320Sensor', () {
    test('should return true with complete data', () {
      String data = "2023_3_30_10_52_53;0;2;3;0;2;3;258;135;76;0.000000;0.000000;0.00;0.00;0;19.06;100649.77;19.95;69.39;4.05;12.75;1.05;19.30;58.50";
      DataPointModel point = DataPointModel(id: 0, values: data.split(';'), sensorName: "sensorName", position: Position());
      bool result = point.hasAM2320Sensor();
      expect(result, true);
    });

    test('should return true with data having lots of fields', () {
      String data = "2023_3_30_10_52_53;0;2;3;0;2;3;258;135;76;0.000000;0.000000;0.00;0.00;0;19.06;100649.77;19.95;69.39;4.05;12.75;1.05;19.30;58.50;92.51:42.42";
      DataPointModel point = DataPointModel(id: 0, values: data.split(';'), sensorName: "sensorName", position: Position());
      bool result = point.hasAM2320Sensor();
      expect(result, true);
    });

    test('should return false with data missing fields', () {
      String data = "2023_3_30_10_52_53;0;2;3;0;2;3;258;135;76;0.000000;0.000000;0.00;0.00;0;19.06;100649.77;19.95;69.39;4.05;12.75;1.05";
      DataPointModel point = DataPointModel(id: 0, values: data.split(';'), sensorName: "sensorName", position: Position());
      bool result = point.hasAM2320Sensor();
      expect(result, false);
    });
  });
}