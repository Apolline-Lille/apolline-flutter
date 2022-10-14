import 'dart:async';
import 'package:apollineflutter/utils/position/position.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:geolocator/geolocator.dart' as geo;

///
///Author (Issagha Barry)
///Location service.
class SimpleLocationService {

  ///current position.
  late Position _currentPosition;
  ///stream.
  StreamController<Position> _locationStream = StreamController<Position>();
  late StreamSubscription<geo.Position> _locationSubscription;

  ///
  ///constructor.
  SimpleLocationService() {
    geo.Geolocator.requestPermission().then((permission) {
      if(permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
        this._locationStream.add(Position());
      }
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

  void start () async {
    this._locationStream = StreamController<Position>();
    this._locationSubscription = geo.Geolocator.getPositionStream().listen((p) {
      this._locationStream.add(Position(geohash: SimpleGeoHash.encode(p.latitude, p.longitude)));
    });
  }

  /// Removes all stream listeners and close it.
  void close () async {
    this._locationSubscription.cancel();
    this._locationStream.close();
  }
}