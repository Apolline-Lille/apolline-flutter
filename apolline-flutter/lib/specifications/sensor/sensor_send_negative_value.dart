import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

class SensorSendNegativeValue extends LeafSpecification {

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate < 0;
  }
  
}