import 'dart:async';

import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/sensormodel.dart';
import 'package:apollineflutter/utils/position.dart';
import 'package:apollineflutter/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:apollineflutter/models/sensor_device.dart';

import 'services/realtime_data_service.dart';
import 'services/service_locator.dart';
import 'widgets/maps.dart';
import 'widgets/quality.dart';
import 'widgets/stats.dart';
import 'services/influxdb_client.dart';


enum ConnexionType { Normal, Disconnect }

class SensorView extends StatefulWidget {
  SensorView({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;
  bool isConnected = false;

  @override
  State<StatefulWidget> createState() => _SensorViewState();
}

class _SensorViewState extends State<SensorView> {
  String state = "Connecting to the device...";
  String buf = "";
  SensorModel lastReceivedData;
  bool initialized = false;
  StreamSubscription sub; //used for remove listening value to sensor
  bool isConnected = false;

  List<StreamSubscription> subs =
      []; //used for remove listening value to sensor
  StreamSubscription subData;
  bool showErrorAction = false;
  Timer timer;
  ConnexionType connectType = ConnexionType.Normal;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  InfluxDBAPI _service = InfluxDBAPI();
  Position _currentPosition;

  RealtimeDataService _dataService = locator<RealtimeDataService>();

  /* Called when data is received from the sensor */
  void _handleCharacteristicUpdate(List<int> value) {
    String s = String.fromCharCodes(value);
    buf += s;

    if (buf.contains('\n')) {
      print("Got full line: " + buf);
      List<String> values = buf.split(';');
      var position = this._currentPosition ?? Position();
      /* Split values in a parseable format, and send them to the UI */
      setState(() {
        lastReceivedData = SensorModel(values: values, device: SensorDevice(widget.device), position: position);
        _service.write(lastReceivedData.fmtToInfluxData());
        _dataService.update(values);
        initialized = true;

        /* Perform additional handling here */
      });
      buf = "";
    }
  }

  void updateState(String st) {
    print(st);
    setState(() {
      state = st;
    });
  }

  ///
  ///
  void handleNotification(BluetoothCharacteristic c) {
    subData = c.value.listen((value) {
      if (connectType == ConnexionType.Disconnect) {
        //tester si on est dans le cas d'une reconnexion
        connectType = ConnexionType.Normal;
        showSnackbar("Capteur reconnecté !");
      }

      _handleCharacteristicUpdate(value);
    });

    /* Now we tell the sensor to start sending data by sending char 'c' (?) */
    timer = Timer(Duration(seconds: 5), () {
      //updateState("Starting up streaming");
      c.write([0x63]).then((s) {
        print("Requested streaming start");
      }).catchError((e) {
        print(e);
      });
    });
  }

  void handleServiceDiscovered(BluetoothService service) {
    if (service.uuid.toString().toLowerCase() ==
        BlueSensorAttributes.DustSensorServiceUUID) {
      updateState("Blue Sensor Dust Sensor found - configuring characteristic");
      var characteristics = service.characteristics;

      /* Search for the Dust Sensor characteristic */
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString().toLowerCase() ==
            BlueSensorAttributes.DustSensorCharacteristicUUID) {
          updateState("Characteristic found - reading, NOtification flag is " +
              c.properties.notify.toString());

          /* Enable notification */
          updateState("Enable notification");

          c.setNotifyValue(true).then((s) {
            /* Catch updates on characteristic  */
          }).catchError((e) {
            print(e);
          }).whenComplete(() {
            handleNotification(c);
          });
        }
      }
    }
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

  ///
  ///Function to be executed after a connection
  void pastConnect() {
    isConnected = true;
    setState(() {
      showErrorAction = false;
    });
    subData?.cancel();
    handleDeviceConnect(widget.device);
  }

  ///
  ///Function to be executed after disconnection
  void passDisconnect() {
    isConnected = false;
    buf = "";
    connectType = ConnexionType.Disconnect; //deconnexion
    timer?.cancel();
    setState(() {
      showErrorAction = true;
    });
    showSnackbar("Connection perdu avec le capteur !");
  }

  ///
  ///Display a snackBar
  void showSnackbar(String msg) {
    var snackbar = SnackBar(content: Text(msg));
    if (_scaffoldKey != null && _scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  ///
  ///
  void handleDeviceConnect(BluetoothDevice d) {
    var sub = widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnecting) {
        /*TODO: detectecter quand cela arrive */
      } else if (state == BluetoothDeviceState.disconnected) {
        passDisconnect();
      } else if (state == BluetoothDeviceState.connected) {
        print("--------------------connected--------------");
        if (connectType == ConnexionType.Disconnect && !isConnected) {
          pastConnect();
        }
      } else {
        print("--------------------connecting------------");
      }
    });
    subs.add(sub);

    updateState("Configuring device");
    List<BluetoothService> services;
    d.discoverServices().then((s) {
      /* Discover services, and search for the Dust Sensor service */
      s.forEach((service) {
        handleServiceDiscovered(service);
      });
    });
  }

  Future<void> initializeDevice() async {
    print("Connecting to device");

    try {
      await widget.device.connect();
      isConnected = true;
      /* TODO: voir s'il ya possibilité de négocier le mtu */
    } catch (e) {
      if (e.code != "already_connected") {
        throw e;
      }
      if (e.code == "already_connected") {
        isConnected = true;
      }
    } finally {
      handleDeviceConnect(widget.device);
    }
  }

  void initializeLocation() {
    SimpleLocationService().locationStream.listen((p) {
      this._currentPosition = p;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDevice();
    initializeLocation();
  }

  @override
  void dispose() {
    subs.forEach((sub) {
      sub.cancel();
    });
    if (subData != null) {
      subData.cancel();
    }
    timer?.cancel();
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
          title: Text(widget.device.name),
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
                body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
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
