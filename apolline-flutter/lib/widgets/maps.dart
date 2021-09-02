import 'dart:async';
import 'dart:collection';

import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/time_filter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/utils/simple_geohash.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:apollineflutter/configuration_key_name.dart';
import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/services/location_service.dart';


class MapSample extends StatelessWidget {
  MapSample() : super();

  @override
  Widget build(BuildContext context) {
    return const MapUiBody();
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  
  ///the min value of pm order in data point.
  var minPmValues = GlobalConfiguration().get(ApollineConf.MINPMVALUES) ?? [];
  ///the max value of pm order in data point.
  var maxPmValues = GlobalConfiguration().get(ApollineConf.MAXPMVALUES) ?? [];
  ///user configuration in the ui
  UserConfigurationService ucS = locator<UserConfigurationService>();
  ///instance to manage database
  SqfLiteService _sqliteService = SqfLiteService();
  ///circle to put in map
  Set<Circle> _circles;
  ///help for close subscription
  StreamSubscription _sub;
  ///help to listen data
  Stream<DataPointModel> _sensorDataStream = locator<RealtimeDataService>().dataStream;
  
  MapUiBodyState();

  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(50.6333, 3.0667),
    zoom: 11.0,
  );

  GoogleMapController _controller;
  SimpleLocationService _locationService;

  @override
  void initState() {
    super.initState();
    this._circles = HashSet<Circle>();
    this.getSensorDataAfterDate();
    this.listenSensorData();
    this._locationService = SimpleLocationService();
  }

  ///
  ///Listen sensor data.
  void listenSensorData() {
    this._sub = this._sensorDataStream.listen((pModel) {
      if(pModel.position.geohash != "no") {
        this.addCircle(pModel);
        //manage the rendering frequency.
        if(this._circles.length % 10 == 0) {
          this.setState(() { });
        }
      }
    });
  }

  @override
  void dispose() {
    this._sub?.cancel();
    this._locationService.close();
    super.dispose();
  }

  ///
  ///This function build a radio button for mapSync
  ///[context] the context
  ///[labels] the label
  ///[values] all value 
  List<Widget> frequencyRadio(BuildContext context, List<String> labels, List<dynamic> values, dynamic current) {
    List<Widget> renders = [];
    for(var i = 0; i < labels.length; i++) {
      renders.add(
        ListTile(
          title: Text(labels[i]),
          leading: Radio(
            value: values[i], //we use index for maping label et MapFrequency
            groupValue: current,
            onChanged: (dynamic value) {
              Navigator.pop(context, values[i]);
            },
          ),
          onTap: () => Navigator.pop(context, values[i]),
        ),
      );
    }
    return renders;
  }

  ///
  ///Create dialog for select.
  ///[ctx] the context of app
  ///[labels] label in the select
  ///[values] the values corresponding to labels
  ///[current] the current value of select
  Future<dynamic> dialog(BuildContext ctx, List<String> labels, List<dynamic> values, dynamic current) async{
    var val = await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left:0),
          content: Container(
            height: 300,
            width: 300,
            child: ListView(
              children: this.frequencyRadio(context, labels, values, current),
            )
          ),
        );
      }
    );
    return val;
  }

  ///
  ///select for time
  ///[ctx] the context of app
  Future<void> chooseTimeFilter(BuildContext ctx) async{
    var uConf = this.ucS.userConf;
    var val = await this.dialog(ctx, TimeFilterUtils.getLabels(), TimeFilter.values, uConf.timeFilter);
    if(val != null) {
      uConf.timeFilter = val;
      this.ucS.update(); //notify the settings page that something has changed.
      this.getSensorDataAfterDate();
    }
  }

  ///
  ///select for choose pm.
  ///[ctx] the context of app
  Future<void> choosePm(BuildContext ctx) async {
    var uConf = this.ucS.userConf;
    var val = await this.dialog(ctx, PMFilterUtils.getLabels(), PMFilter.values, uConf.pmFilter);
    if(val != null) {
      uConf.pmFilter = val;
      this.ucS.update();
      this.getSensorDataAfterDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      zoomControlsEnabled: false,
      indoorViewEnabled: true,
      myLocationEnabled: true,
      circles: this._circles,
    );

    return new Scaffold(
      body: googleMap,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              label: Text("Time"),
              onPressed: () { this.chooseTimeFilter(context); }
            ),
            FloatingActionButton.extended(
              label: Text("PM"),
              onPressed: () { this.choosePm(context); }
            )
          ],
        ),
      ),
    );
  }


  ///
  ///Get the color fonction of pm25 value
  Color getColorOfPM25(double pmValue) {
    var index = this.ucS.userConf.pmFilter.getRowIndex();

    var min = index >= 0 && index < this.minPmValues.length ? this.minPmValues[index] : 0;
    var max = index >= 0 && index < this.maxPmValues.length ? this.maxPmValues[index] : 1;
    if(pmValue < min) {
      return Color.fromRGBO(170, 255, 0, .1); //vert
    } else if(pmValue >= min && pmValue <= max) {
      return Color.fromRGBO(255, 143, 0, .1); //orange
    } else {
      return Color.fromRGBO(255, 15, 0, .1); //rouge
    }
  }

  ///
  ///add circle to model.
  ///[pModel] model
  void addCircle(DataPointModel pModel) {
    var json = SimpleGeoHash.decode(pModel.position.geohash);
    this._circles.add(
      Circle(
        circleId: CircleId(UniqueKey().toString()),
        center: LatLng(json["latitude"], json["longitude"]),
        radius: 10,
        strokeWidth: 0,
        fillColor: this.getColorOfPM25(double.parse(pModel.values[this.ucS.userConf.pmFilter.getRowIndex()]))
      )
    );
  }

  ///
  ///update data after change time of pm choice.
  void getSensorDataAfterDate() async {
    List<DataPointModel> models = await this._sqliteService.getAllDataPointsAfterDate(this.ucS.userConf.timeFilter);
    print("Got ${models.length} results for ${this.ucS.userConf.timeFilter} with filter=${this.ucS.userConf.pmFilter}.");
    List<DataPointModel> circleModels = models.where((model) => model.position.geohash != 'no').toList();

    setState(() {
      this._circles.clear(); //clean last content.
      circleModels.forEach((model) {
        addCircle(model);
      });
    });

    print("${this._circles.length} circles added.");
  }

  ///
  /// Call when map is create.
  /// [controller] GoogleMapController help to do something.
  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
    this._locationService.getLocation().then((position) {
      if(position.geohash != "no") {
        var json = SimpleGeoHash.decode(position.geohash);
        this._kInitialPosition = CameraPosition(
          target: LatLng(json["latitude"], json["longitude"]),
          zoom: 18.0,
        );
      }
      this._controller.animateCamera(CameraUpdate.newCameraPosition(this._kInitialPosition));
    });
  }
}
