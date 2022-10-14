///
/// This enumeration represents all position sources.
///
enum PositionProvider {
  PHONE,
  SENSOR,
  UNKNOWN
}

extension PositionProviderExtension on PositionProvider {
  String get value {
    switch (this) {
      case PositionProvider.PHONE:
        return 'phone';
      case PositionProvider.SENSOR:
        return 'sensor';
      case PositionProvider.UNKNOWN:
        return 'unknown';
    }
  }
}