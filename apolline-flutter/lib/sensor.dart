import 'dart:async';

import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/sensormodel.dart';
import 'package:apollineflutter/utils/position.dart';
import 'package:apollineflutter/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:apollineflutter/models/sensor_device.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'package:apollineflutter/models/sensor_collection.dart';

import 'services/realtime_data_service.dart';
import 'services/service_locator.dart';
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
  String buf = "";
  SensorModel lastReceivedData;
  bool initialized = false;
  StreamSubscription subBluetoothState; //used for remove listening value to sensor
  StreamSubscription subLocation;
  bool isConnected = false;
  SensorCollection lastData = SensorCollection();

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
      
      var model = SensorModel(values: values, device: SensorDevice(widget.device), position: position);
      _dataService.update(values);
      this.updateOrWriteData(model);
      
      setState(() {
        lastReceivedData = model;
        initialized = true;

        /* Perform additional handling here */
      });
      buf = "";
    }
  }

  void updateOrWriteData(SensorModel model) {
    if(this.lastData.length >= 60) {
      _service.write(this.lastData.fmtToInfluxData());
      this.lastData.clear();
    } else {
      this.lastData.addModel(model);
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
  void postConnect() {
    setState(() {
      showErrorAction = false;
    });
    handleDeviceConnect(widget.device);
  }

  ///
  ///Function to be executed after disconnection
  void postDisconnect() {
    isConnected = false;
    buf = "";
    connectType = ConnexionType.Disconnect; //deconnexion
    this.destroyStream();
    setState(() {
      showErrorAction = true;
    });
    showSnackbar("Connection perdu avec le capteur !");
  }

  ///use for prevent when setState call after dispose methode.
  @override
  void setState(fn) {
    if(this.mounted){
      super.setState(fn);
    }
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
  ///listen device state.
  void listenDeviceState() {
    this.subBluetoothState = widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnecting) {
        /*TODO: detectecter quand cela arrive */
      } else if (state == BluetoothDeviceState.disconnected) {
        postDisconnect();
      } else if (state == BluetoothDeviceState.connected) {
        print("--------------------connected--------------");
        if (connectType == ConnexionType.Disconnect && !isConnected) {
          postConnect();
        }
      } else {
        print("--------------------connecting------------");
      }
    });
  }

  ///
  ///
  void handleDeviceConnect(BluetoothDevice d) {
    
    if(!isConnected) {
      isConnected = true;
      updateState("Configuring device");
      d.discoverServices().then((s) {
        /* Discover services, and search for the Dust Sensor service */
        s.forEach((service) {
          handleServiceDiscovered(service);
        });
      });

    }

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
      listenDeviceState();
      handleDeviceConnect(widget.device);
    }
  }

  void initializeLocation() {
    this.subLocation = SimpleLocationService().locationStream.listen((p) {
      this._currentPosition = p;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDevice();
    initializeLocation();
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
