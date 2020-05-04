import 'dart:collection';

import 'package:apollineflutter/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(ApollineApp());

// This acts as the landing window of the app.
// Scans and displays Bluetooth devices in range, and allows to connect to them.

class ApollineApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apolline',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: BluetoothDevicesPage(title: 'Apolline - Sensors'),
    );
  }
}

class BluetoothDevicesPage extends StatefulWidget {
  BluetoothDevicesPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BluetoothDevicesPageState createState() => _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  String state = "Scanning...";
  Map<String,BluetoothDevice> devices = {};

  @override
  void initState() {
    super.initState();
    _performDetection();
  }

  /* Starts BLE detection */
  void _performDetection()
  {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 10));

    /* For each result, insert into the detected devices list if not already present */
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {devices.putIfAbsent (r.device.id.toString(), () => r.device);} );
      }
    });

    setState(() {
      state = "Detected devices:";
    });
  }

  /* Build the UI list of detected devices */
  List<Widget> _buildDevicesList() {
    List<Widget> wList = new List<Widget>();
    /* Add the state label at the top */
    wList.add(Text(state));

    /* Add a button for each device */
    /* TODO: filter device list */
    devices.forEach((id, d) {
        if(!wList.contains(d))
        wList.add(Card(child: ListTile(title: Text(d.name), subtitle: Text(id), onTap: () {
          connectToDevice(d);
        },)));
      });

    return wList;
  }

  /* Handles a click on a device entry */
  void connectToDevice(BluetoothDevice device)
  {
    /* Stop scanning, if not already stopped */
    FlutterBlue.instance.stopScan();

    /* We selected a device - go to the device screen passing information about the selected device */
    Navigator.push(context,
      MaterialPageRoute(builder : (context) => SensorView(device: device)),
    );
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    /* Scan for BLE devices (should be once) */
    //_performDetection();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          child: ListView(
              children: _buildDevicesList()
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _performDetection,
        tooltip: 'Rescan',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
