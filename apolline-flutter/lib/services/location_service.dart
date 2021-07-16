import 'dart:async';
import 'package:apollineflutter/utils/position.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:geolocator/geolocator.dart' as geo;

///
///Author (Issagha Barry)
///Location service.
class SimpleLocationService {

  ///current position.
  Position _currentPosition;
  ///stream.
  ///TODO close stream
  // ignore: close_sinks
  StreamController<Position> _locationStream = StreamController<Position>.broadcast();

  ///
  ///constructor.
  SimpleLocationService() {
    geo.Geolocator.requestPermission().then((permission) {
      if(permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
        this._locationStream.add(Position());
      }
      geo.Geolocator.getPositionStream().listen((p) {
        if(p != null) {
          this._locationStream.add(Position(geohash: SimpleGeoHash.encode(p.latitude, p.longitude)));
        }
      });
    });
  }

  ///location stream.
  Stream<Position> get locationStream => _locationStream.stream;

  ///get location.
  Future<Position> getLocation() async {
    try {
      var p = await geo.Geolocator.getCurrentPosition();
      this._currentPosition = Position(geohash: SimpleGeoHash.encode(p.latitude, p.longitude));
    } catch(e) {
      print('pas pu recupérer la localisation');
      this._currentPosition = Position();
    }

    return this._currentPosition;
  }


}