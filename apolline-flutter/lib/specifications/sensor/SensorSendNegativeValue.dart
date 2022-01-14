import 'package:apollineflutter/specifications/operations/LeafSpecification.dart';

class SensorSendNegativeValue extends LeafSpecification {

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate < 0;
  }
  
}