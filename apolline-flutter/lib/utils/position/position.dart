import 'package:apollineflutter/utils/position/position_provider.dart';

///
///Position.
class Position {
  /// Latitude and longitude linked by a ";" character.
  /// Those are stored as a string not to break compatibility with previous
  /// database versions.
  String geohash;

  /// The transport.
  String transport;

  /// Source of the current position.
  PositionProvider provider;

  ///
  ///Constructor.
  Position({
    this.geohash="no",
    this.transport="no",
    this.provider = PositionProvider.UNKNOWN
  });

  String toInfluxDbFormat() {
    List<String> words = geohash.split(";");
    return geohash == "no"
        ? "geohash=no"
        : "latitude=${words.first},longitude=${words.last}";
  }
}