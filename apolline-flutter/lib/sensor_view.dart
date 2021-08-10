import 'dart:async';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/twins/SensorTwin.dart';
import 'package:apollineflutter/twins/SensorTwinEvent.dart';
import 'package:apollineflutter/utils/position.dart';
import 'package:apollineflutter/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'models/sensormodel.dart';
import 'services/realtime_data_service.dart';
import 'services/service_locator.dart';
import 'widgets/maps.dart';
import 'widgets/quality.dart';
import 'widgets/stats.dart';
import 'package:apollineflutter/services/service_locator.dart';

enum ConnexionType { Normal, Disconnect }

class SensorView extends StatefulWidget {
  SensorView({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => _SensorViewState();
}

class _SensorViewState extends State<SensorView> {
  String state = "Connecting to the device...";
  String buf = "";
  SensorModel lastReceivedData;
  bool initialized = false;
  StreamSubscription subBluetoothState; //used for remove listening value to sensor
  StreamSubscription subLocation;
  bool isConnected = false;
  List<StreamSubscription> subs = []; //used for remove listening value to sensor
  StreamSubscription subData;
  bool showErrorAction = false;
  Timer timer, timerSynchro;
  ConnexionType connectType = ConnexionType.Normal;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // use for influxDB to send data to the back
  InfluxDBAPI _service = InfluxDBAPI();
  // use for sqfLite to save data in local
  SqfLiteService _sqfLiteService = SqfLiteService();
  Position _currentPosition;
  SensorTwin _sensor;

  RealtimeDataService _dataService = locator<RealtimeDataService>();


  @override
  void initState() {
    super.initState();
    initializeDevice();
    initializeLocation();
    //synchronisation data
    this.timerSynchro = Timer.periodic(Duration(seconds: 120), (Timer t) => synchronizeData());
  }


  ///
  ///
  Future<void> initializeDevice() async {
    print("Connecting to device");

    try {
      await widget.device.connect();
      /* TODO: voir s'il ya possibilité de négocier le mtu */
    } catch (e) {
      if (e.code != "already_connected") {
        throw e;
      }
    } finally {
      handleDeviceConnect(widget.device);
    }
  }

  void initializeLocation() {
    this.subLocation = SimpleLocationService().locationStream.listen((p) {
      this._currentPosition = p;
    });
  }


  /* Called when data is received from the sensor */
  void _handleSensorUpdate(String message) {
    buf += message;

    if (buf.contains('\n')) {
      print("Got full line: " + buf);
      List<String> values = buf.split(';');
      var position = this._currentPosition ?? Position();

      var model = SensorModel(values: values, sensorName: _sensor.name, position: position);
      _dataService.update(model);
      /* insert to sqflite */
      _sqfLiteService.insertSensor(model.toJSON());

      setState(() {
        lastReceivedData = model;
        initialized = true;

        /* Perform additional handling here */
      });
      buf = "";
    }
  }

  ///
  /// Retrieves all data points from local database that have not been sent
  /// to InfluxDB yet, and sends them.
  ///
  void synchronizeData() async {
    // find not-synchronized data
    int pagination = 160;
    List<SensorModel> dataPoints = await _sqfLiteService.getAllSensorModelsNotSyncro();
    if (dataPoints.length == 0) return;

    // Paginating data before sending to influxDB
    var iter = (dataPoints.length / pagination).ceil();
    for (var i = 0; i < iter; i++) {
      int start = i * pagination;
      int end = (i + 1) * pagination;
      if (1 == iter || i + 1 == iter) {
        end = dataPoints.length;
      }
      var sousList = dataPoints.sublist(start, end);

      // Send data to influxDB
      await _service.write(SensorModel.sensorsFmtToInfluxData(sousList));
      List<int> ids = [];
      dataPoints.forEach((sousList) {
        ids.add(sousList.id);
      });
      // Update local data in sqfLite
      _sqfLiteService.updateSensorSynchronisation(ids);
    }
  }

  void updateState(String st) {
    print(st);
    setState(() {
      state = st;
    });
  }


  ///
  /// Builds up a sensor instance from a Bluetooth device.
  /// Sets up data listeners before starting live data transfer.
  ///
  void handleDeviceConnect(BluetoothDevice device) async {
    if (isConnected) return;
    isConnected = true;

    updateState("Configuring device");
    this._sensor = SensorTwin(device: device);
    this._sensor.on(SensorTwinEvent.live_data, (data) {
      _handleSensorUpdate(data);
    });
    this._sensor.on(SensorTwinEvent.sensor_connected, (_) {
      print("--------------------connected--------------");
      if (connectType == ConnexionType.Disconnect && !isConnected) {
        print("-------------------connectedExécute---------");
        setState(() {
          showErrorAction = false;
        });
        handleDeviceConnect(widget.device);
      }
    });
    this._sensor.on(SensorTwinEvent.sensor_disconnected, (_) {
      print("----------------disconnected----------------");
      buf = "";
      this.destroyStream();
      isConnected = false;
      connectType = ConnexionType.Disconnect; //deconnexion
      setState(() {
        showErrorAction = true;
      });
      showSnackbar("Connection perdu avec le capteur !");
    });
    await this._sensor.init();
    await this._sensor.launchDataLiveTransmission();
    updateState("Waiting for sensor data...");
  }


  ///
  ///Allows you to give information when you are unable to reconnect
  Future<void> showInformation() async {
    var text = "L'appareil sensor est soit éteint ou distant," +
        "veuillez vous assurez que l'appareil est chargé et près de votre téléphone;" +
        " faite un retour en arrière ou fermé et réouvré l'application; " +
        "sinon contactez l'administrateur";
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            Text(text),
          ],
        );
      },
    );
  }


  ///use for prevent when setState call after dispose methode.
  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  ///
  ///Display a snackBar
  void showSnackbar(String msg) {
    var snackbar = SnackBar(content: Text(msg));
    if (_scaffoldKey != null && _scaffoldKey.currentState != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // _scaffoldKey.currentState.hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      // _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }


  ///
  ///detroy partiel stream when loose connection.
  void destroyStream() {
    this.subData?.cancel();
    this.timer?.cancel();
  }

  @override
  void dispose() {
    this.destroyStream();
    this.subBluetoothState?.cancel();
    this.subLocation?.cancel();
    widget.device.disconnect();
    this.timerSynchro?.cancel();
    super.dispose();
  }

  ///
  ///
  List<Widget> _buildAppBarAction() {
    return showErrorAction
        ? <Widget>[
            IconButton(
                icon: Icon(Icons.error),
                onPressed: () {
                  showInformation();
                })
          ]
        : [];
  }

  ///
  ///Called when press back button
  Future<bool> _onWillPop() async {
    Navigator.pop(context, isConnected);
    return false;
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    /* If we are not initialized, display status info */
    if (!initialized) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_sensor != null ? _sensor.name : "Loading..."),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, isConnected);
              }),
          actions: _buildAppBarAction(),
        ),
        body: Center(
          child: Column(children: <Widget>[
            CupertinoActivityIndicator(),
            Text(state),
          ]),
        ),
      );
    } else {
      /* We got data : display them */
      return WillPopScope(
        onWillPop: _onWillPop,
        child: MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: Colors.green,
                  bottom: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.insert_chart)),
                      Tab(icon: Icon(Icons.map)),
                    ],
                  ),
                  title: Text('Apolline'),
                ),
                body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
                  Quality(lastReceivedData: lastReceivedData),
                  Stats(dataSensor: lastReceivedData),
                  MapSample(),
                ])),
          ),
        ),
      );
    }
  }
}
