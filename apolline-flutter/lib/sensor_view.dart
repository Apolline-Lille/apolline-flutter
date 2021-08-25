import 'dart:async';
import 'package:apollineflutter/twins/SensorTwin.dart';
import 'package:apollineflutter/twins/SensorTwinEvent.dart';
import 'package:apollineflutter/utils/device_connection_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/data_point_model.dart';
import 'widgets/maps.dart';
import 'widgets/quality.dart';
import 'widgets/stats.dart';



enum ConnexionType { Normal, Disconnect }


class SensorView extends StatefulWidget {
  SensorView({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => _SensorViewState();
}


class _SensorViewState extends State<SensorView> {
  String state = "Connecting to the device...";
  DataPointModel lastReceivedData;
  bool isConnected = false;
  ConnexionType connectType = ConnexionType.Normal;
  SensorTwin _sensor;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  @override
  void initState() {
    super.initState();
    initializeDevice();
  }


  ///
  ///
  Future<void> initializeDevice() async {
    print("Connecting to device");
    bool isConnectedToDevice = true;

    try {
      await widget.device.connect().timeout(Duration(seconds: 3), onTimeout: () {
        isConnectedToDevice = false;
        if (_scaffoldMessengerKey.currentContext != null) {
          Fluttertoast.showToast(msg: "Impossible de se connecter à cet appareil.");
          this._onWillPop(DeviceConnectionStatus.UNABLE_TO_CONNECT);
        }
      });
    } catch (e) {
      if (e.code != "already_connected") {
        throw e;
      }
    } finally {
      if (isConnectedToDevice)
        handleDeviceConnect(widget.device);
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
    if (this._sensor != null) {
      this._sensor.shutdown();
      await widget.device.connect();
    }

    updateState("Configuring device");
    this._sensor = SensorTwin(device: device, syncTiming: Duration(minutes: 2));
    this._sensor.on(SensorTwinEvent.live_data, (d) => _onLiveDataReceived(d as DataPointModel));
    this._sensor.on(SensorTwinEvent.sensor_connected, (_) => _onSensorConnected());
    this._sensor.on(SensorTwinEvent.sensor_disconnected, (_) => _onSensorDisconnected());
    await this._sensor.init();
    await this._sensor.launchDataLiveTransmission();
    updateState("Waiting for sensor data...");
  }

  void _onLiveDataReceived (DataPointModel model) {
    setState(() {
      lastReceivedData = model;
    });
  }

  void _onSensorConnected () {
    if (connectType == ConnexionType.Disconnect && !isConnected) {
      print("-------------------connectedExécute---------");
      handleDeviceConnect(widget.device);
    } else {
      print("--------------------connected--------------");
      showSnackBar("Connexion avec le capteur établie.");
    }
  }

  void _onSensorDisconnected () {
    print("----------------disconnected----------------");
    isConnected = false;
    connectType = ConnexionType.Disconnect; //deconnexion
    showSnackBar("Connexion avec le capteur perdue.", duration: Duration(days: 1));
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
  void showSnackBar(String msg, {Duration duration = const Duration(seconds: 4)}) {
    var snackBar = SnackBar(content: Text(msg), duration: duration,);
    ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext).hideCurrentSnackBar();
    ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext).showSnackBar(snackBar);
  }


  @override
  void dispose() {
    widget.device.disconnect();
    this._sensor?.shutdown();
    super.dispose();
  }


  ///
  ///Called when press back button
  Future<bool> _onWillPop(DeviceConnectionStatus status) async {
    if (_scaffoldMessengerKey.currentContext != null) {
      ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext).hideCurrentSnackBar();
      Navigator.pop(context, status);
    }

    return false;
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    /* If we are not initialized, display status info */
    if (lastReceivedData == null) {
      return Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: Text(_sensor != null ? _sensor.name : "Connecting to sensor..."),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onWillPop(DeviceConnectionStatusHelper.fromConnectionStatus(isConnected));
              }),
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
        onWillPop: () => _onWillPop(DeviceConnectionStatusHelper.fromConnectionStatus(isConnected)),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
              key: _scaffoldMessengerKey,
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
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
                Stats(),
                MapSample(),
              ])),
        ),
      );
    }
  }
}
