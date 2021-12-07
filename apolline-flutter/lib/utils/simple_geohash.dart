import 'package:geohash/geohash.dart';
import 'dart:math';


///
///Hash latitude and longitude
class SimpleGeoHash {

  ///
  ///encode [lat] latitude and longitude [long]
  static String encode(double lat, double long, {int codeLength: 10}) {
    return Geohash.encode(lat, long, codeLength: codeLength);
  }

  ///
  ///decode [geohash]
  static Map<String, double> decode(String geohash) {
    Point<double> p = Geohash.decode(geohash);
    return {'latitude': p.x, 'longitude': p.y};
  }
}