import 'package:apollineflutter/sensor_view.dart';
import 'package:apollineflutter/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:apollineflutter/services/local_persistant_service.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/services/service_locator.dart';



class BluetoothDevicesPage extends StatefulWidget {
  BluetoothDevicesPage({Key key, this.title}) : super(key: key);
  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _BluetoothDevicesPageState createState() => _BluetoothDevicesPageState();
}


class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  bool timeout = true;
  Set<BluetoothDevice> devices = Set();
  Set<BluetoothDevice> pairedDevices = Set();
  ///user configuration in the ui
  UserConfigurationService ucS = locator<UserConfigurationService>();

  @override
  void initState() {
    super.initState();
    //initializeDevice();
    this.ucS.addListener(() {
      LocalKeyValuePersistance.saveObject(UserConfigurationService.USER_CONF_KEY, ucS.userConf.toJson());
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
          pairedDevices.add(device);
        });
      }
    });
    /* For each result, insert into the detected devices list if not already present */
    widget.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.length > 0) {
          setState(() {
            devices.add(r.device);
          });
        }
      }
    });
  }

  void _addWidgetDevices(Set<BluetoothDevice> devices, List<Widget> l, Function(List<Widget>, BluetoothDevice) cond) {
    devices.toList().forEach((device) {
      if (cond(l, device))
        l.add(
            DeviceCard(device: device, connectionCallback: connectToDevice)
        );
    });
  }

  bool _conditionForDevices(List<Widget> l, BluetoothDevice d) {
    return (!pairedDevices.contains(d)) && (!l.contains(d));
  }

  bool _conditionForPaireddevices(List<Widget> l, BluetoothDevice d) {
    return !l.contains(d);
  }

  /* Build the UI list of detected devices */
  List<Widget> _buildDevicesList() {
    List<Widget> wList = [];

    if (pairedDevices.length > 0) {
      wList.add(Container(
        child: Text("Périphérique appairés"),
        margin: EdgeInsets.only(top: 10, bottom: 10)
      ));
      _addWidgetDevices(pairedDevices, wList, _conditionForPaireddevices);
    }

    wList.add(Container(
      margin: EdgeInsets.only(top: pairedDevices.length > 0 ? 30 : 10, bottom: 10),
      child: Text("Appareils disponibles")
    ));
    _addWidgetDevices(devices, wList, _conditionForDevices);

    /* Add a button for each device */
    /* TODO: filter device list */

    return wList;
  }

  /* Handles a click on a device entry */
  void connectToDevice(BluetoothDevice device) async {
    /* Stop scanning, if not already stopped */
    FlutterBlue.instance.stopScan();
    /* We selected a device - go to the device screen passing information about the selected device */
    var isconnected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SensorView(device: device)),
    );

    if (isconnected != null && isconnected) {
      setState(() {
        devices.remove(device);
        pairedDevices.add(device);
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
    const btnStyle = TextStyle(color: Colors.white);
    Color bgColor = Theme.of(context).primaryColor;

    if (timeout) {
      return <Widget>[
        // ignore: missing_required_param
        TextButton(child: Text("Analyser", style: btnStyle,)),
      ];
    } else {
      return <Widget>[
        SizedBox(
          child: Theme(
            data: Theme.of(context).copyWith(accentColor: bgColor),
            child: CircularProgressIndicator(backgroundColor: Colors.white),
          ),
          width: 20,
          height: 20,
        ),
        // ignore: missing_required_param
        TextButton(child: Text("Arrêter", style: btnStyle)),
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
          child: Container(
            child: ListView(children: _buildDevicesList()),
            margin: EdgeInsets.all(10),
          )),
    );
  }
}
