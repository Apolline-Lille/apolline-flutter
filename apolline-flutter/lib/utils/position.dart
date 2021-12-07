

///
///Position.
class Position {
  ///[provider] the provider
  ///[geohash] the hash of latitude and longitude
  ///[transport] the transport
  String provider, geohash, transport;

  ///
  ///Constructor.
  Position({this.provider="no", this.geohash="no", this.transport="no"});

}