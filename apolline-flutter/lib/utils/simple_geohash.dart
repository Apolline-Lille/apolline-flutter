

///
///Hash latitude and longitude
class SimpleGeoHash {

  ///
  ///encode [lat] latitude and longitude [long]
  static String encode(double lat, double long, {int codeLength: 10}) {
    return "$lat;$long"; // Geohash.encode(lat, long, codeLength: codeLength);
  }

  ///
  ///decode [geohash]
  static Map<String, double> decode(String geohash) {
    // Point<double> p = Geohash.decode(geohash);
    var words = geohash.split(";");
    return {'latitude': double.parse(words[0]), 'longitude': double.parse(words[1])};
  }
}