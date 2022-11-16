///
/// This enumeration represents all position sources.
///
enum PositionProvider {
  PHONE,
  SENSOR,
  UNKNOWN
}

extension PositionProviderUtils on PositionProvider {
  static final Map<PositionProvider, String> _values = {
    PositionProvider.PHONE: 'phone',
    PositionProvider.SENSOR: 'sensor',
    PositionProvider.UNKNOWN: 'unknown'
  };

  String get value {
    if (PositionProviderUtils._values[this] == null)
      throw RangeError("This PositionProvider has no associated value.");
    return PositionProviderUtils._values[this]!;
  }

  static PositionProvider fromString(String value) {
    // Return UNKNOWN for legacy positions.
    if (value == "no")
      return PositionProvider.UNKNOWN;

    if (!PositionProviderUtils._values.values.contains(value))
      throw RangeError("This value does not match any PositionProvider.");
    return PositionProviderUtils._values.keys.firstWhere((element) => PositionProviderUtils._values[element] == value);
  }
}