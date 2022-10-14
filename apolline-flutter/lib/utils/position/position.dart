

import 'package:apollineflutter/utils/position/position_provider.dart';

///
///Position.
class Position {
  ///[geohash] the hash of latitude and longitude
  ///[transport] the transport
  String geohash, transport;

  // Source of the current position.
  PositionProvider provider;

  ///
  ///Constructor.
  Position({
    this.geohash="no",
    this.transport="no",
    this.provider = PositionProvider.UNKNOWN
  });
}