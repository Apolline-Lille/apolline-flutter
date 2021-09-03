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
import 'package:easy_localization/easy_localization.dart';



class PMMapView extends StatefulWidget {
  ///the min value of pm order in data point.
  final minPmValues = GlobalConfiguration().get(ApollineConf.MINPMVALUES) ?? [];
  ///the max value of pm order in data point.
  final maxPmValues = GlobalConfiguration().get(ApollineConf.MAXPMVALUES) ?? [];
  ///user configuration in the ui
  final UserConfigurationService ucS = locator<UserConfigurationService>();
  ///instance to manage database
  final SqfLiteService sqliteService = SqfLiteService();
  ///help to listen data
  final Stream<DataPointModel> sensorDataStream = locator<RealtimeDataService>().dataStream;

  State<StatefulWidget> createState() => _PMMapViewState();
}



class _PMMapViewState extends State<PMMapView> {
  ///circle to put in map
  Set<Circle> _circles;
  ///help for close subscription
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    this._circles = HashSet<Circle>();
    this.updateCirclesFromData();

    this._sub = widget.sensorDataStream.listen((pModel) {
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
  ///[titleKey] title translation key
  Future<dynamic> dialog(BuildContext ctx, List<String> labels, List<dynamic> values, dynamic current, String titleKey) async{
    var val = await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleKey).tr(),
          contentPadding: EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 20),
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
    var uConf = widget.ucS.userConf;
    var val = await this.dialog(ctx, TimeFilterUtils.getLabels(), TimeFilter.values, uConf.timeFilter, "mapView.timeFilters.title");
    if(val != null) {
      uConf.timeFilter = val;
      widget.ucS.update(); //notify the settings page that something has changed.
      this.updateCirclesFromData();
    }
  }

  ///
  ///select for choose pm.
  ///[ctx] the context of app
  Future<void> choosePm(BuildContext ctx) async {
    var uConf = widget.ucS.userConf;
    var val = await this.dialog(ctx, PMFilterUtils.getLabels(), PMFilter.values, uConf.pmFilter, "mapView.sizeFilters.title");
    if(val != null) {
      uConf.pmFilter = val;
      widget.ucS.update();
      this.updateCirclesFromData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(50.6333, 3.0667),
        zoom: 11.0,
      ),
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
              label: Text("mapView.filters.time").tr(),
              icon: Icon(Icons.access_time),
              onPressed: () { this.chooseTimeFilter(context); }
            ),
            FloatingActionButton.extended(
              label: Text("mapView.filters.size").tr(),
              icon: Icon(Icons.cloud_outlined),
              onPressed: () { this.choosePm(context); }
            )
          ],
        ),
      ),
    );
  }


  ///
  ///Get the color fonction of pm25 value
  Color getPMCircleColor(double pmValue) {
    var index = widget.ucS.userConf.pmFilter.getRowIndex();
    var min = index >= 0 && index < widget.minPmValues.length ? widget.minPmValues[index] : 0;
    var max = index >= 0 && index < widget.maxPmValues.length ? widget.maxPmValues[index] : 1;

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
        fillColor: this.getPMCircleColor(double.parse(pModel.values[widget.ucS.userConf.pmFilter.getRowIndex()]))
      )
    );
  }

  ///
  ///update data after change time of pm choice.
  void updateCirclesFromData() async {
    List<DataPointModel> models = await widget.sqliteService.getAllDataPointsAfterDate(widget.ucS.userConf.timeFilter);
    print("Got ${models.length} results for ${widget.ucS.userConf.timeFilter} with filter=${widget.ucS.userConf.pmFilter}.");
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
  void onMapCreated(GoogleMapController controller) async {
    List<DataPointModel> points = await widget.sqliteService.getAllDataPoints();
    DataPointModel lastPointWithPosition = points.length == 0
        ? null
        : points.lastWhere((point) => point.position.geohash != "no", orElse: () => null);
    CameraPosition pos = lastPointWithPosition == null
        ? CameraPosition(target: LatLng(0, 0), zoom: 18.0)
        : CameraPosition(
          target: LatLng(
              SimpleGeoHash.decode(lastPointWithPosition.position.geohash)['latitude'],
              SimpleGeoHash.decode(lastPointWithPosition.position.geohash)['longitude']
          ),
          zoom: 18.0
        );

    controller.animateCamera(CameraUpdate.newCameraPosition(pos));
  }
}
