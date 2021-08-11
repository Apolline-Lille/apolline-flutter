import 'package:apollineflutter/sensor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:apollineflutter/services/local_persistant_service.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/services/service_locator.dart';

// TODO fix
// ignore: must_be_immutable
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
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool bluetoothIsOn = false;

  @override
  _BluetoothDevicesPageState createState() => _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  String state = "Scanning...";
  bool timeout = true;
  Map<String, BluetoothDevice> devices = {};
  Map<String, BluetoothDevice> pairedDevices = {};
  ///user configuration in the ui
  UserConfigurationService ucS = locator<UserConfigurationService>();

  @override
  void initState() {
    super.initState();
    //initializeDevice();
    this.ucS.addListener(() {
      LocalKeyValuePersistance.saveObject("userconf", ucS.userConf.toJson());
    });
    initializeDevice();
  }

  ///
  ///Permet de tester si le bluetooth est activé ou pas
  Future<void> initializeDevice() async {
    var isOn = await widget.flutterBlue.isOn;
    if (isOn) {
      _performDetection();
    } else {
      showDialogBluetooth();
    }
  }

  ///
  ///Afficher un message pour activer le bluetooth
  void showDialogBluetooth() {
    Widget okbtn = TextButton(
      child: Text("ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Activez votre bluetooth pour détecter des appareils"),
      actions: [okbtn],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  /* Starts BLE detection */
  void _performDetection() {
    // Start scanning
    setState(() {
      timeout = false;
    });

    widget.flutterBlue.startScan(timeout: Duration(seconds: 10)).then((val) {
      setState(() {
        timeout = true;
      });
    });

    widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> ds) {
      for (BluetoothDevice device in ds) {
        setState(() {
          pairedDevices.putIfAbsent(device.id.toString(), () => device);
        });
      }
    });
    /* For each result, insert into the detected devices list if not already present */
    widget.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.length > 0) {
          setState(() {
            devices.putIfAbsent(r.device.id.toString(), () => r.device);
          });
        }
      }
    });

    setState(() {
      state = "Detected devices:";
    });
  }

  void _addWidgetDevices(Map<String, BluetoothDevice> devices, List<Widget> l, Function(List<Widget>, BluetoothDevice) cond) {
    devices.forEach((id, d) {
      if (cond(l, d))
        l.add(Card(
            child: ListTile(
          title: Text(d.name),
          subtitle: Text(id),
          onTap: () {
            connectToDevice(d, id);
          },
        )));
    });
  }

  bool _conditionForDevices(List<Widget> l, BluetoothDevice d) {
    return (!pairedDevices.containsValue(d)) && (!l.contains(d));
  }

  bool _conditionForPaireddevices(List<Widget> l, BluetoothDevice d) {
    return !l.contains(d);
  }

  /* Build the UI list of detected devices */
  List<Widget> _buildDevicesList() {
    List<Widget> wList = [];
    /* Add the state label at the top */
    //wList.add(Text(state)); // TODO: remove
    if (pairedDevices.length > 0) {
      wList.add(Text("Périphérique appairés"));
      _addWidgetDevices(pairedDevices, wList, _conditionForPaireddevices);
    }

    wList.add(Text("Appareils disponibles"));
    _addWidgetDevices(devices, wList, _conditionForDevices);
    /* Add a button for each device */
    /* TODO: filter device list */

    return wList;
  }

  /* Handles a click on a device entry */
  void connectToDevice(BluetoothDevice device, String id) async {
    /* Stop scanning, if not already stopped */
    FlutterBlue.instance.stopScan();
    /* We selected a device - go to the device screen passing information about the selected device */
    var isconnected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SensorView(device: device)),
    );

    if (isconnected != null && isconnected) {
      setState(() {
        devices.remove(id);
        pairedDevices.putIfAbsent(id, () => device);
      });
    }
  }

  ///
  ///Exécuter lorsqu'on clique sur le button Annalyser ou Arreter
  void _onPressLookforButton() {
    if (timeout == true) {
      initializeDevice();
    } else {
      widget.flutterBlue.stopScan();
    }
  }

  List<Widget> _buildChildrenButton() {
    if (timeout) {
      return <Widget>[
        // ignore: missing_required_param
        TextButton(child: Text("Analyser")),
      ];
    } else {
      return <Widget>[
        SizedBox(
          child: CircularProgressIndicator(backgroundColor: Colors.blue), //TODO choisir une meilleur couleur
          width: 20,
          height: 20,
        ),
        // ignore: missing_required_param
        TextButton(child: Text("Arrêter")),
      ];
    }
  }

  List<Widget> _buildAppBarAction() {
    List<Widget> wList = <Widget>[
      TextButton(
        onPressed: () {
          _onPressLookforButton();
        },
        child: Row(children: _buildChildrenButton()),
      ),
    ];
    return wList;
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
        actions: _buildAppBarAction(),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: ListView(children: _buildDevicesList())),
    );
  }
}
