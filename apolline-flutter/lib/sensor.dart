import 'dart:collection';

import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/sensormodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  /* Called when data is received from the sensor */
  void _handleCharacteristicUpdate(List<int> value)
  {
    String s = String.fromCharCodes(value);
    buf += s;

    if(buf.contains('\n'))
      {
        print("Got full line: " + buf);
        List<String> values = buf.split(';');
        /* Split values in a parseable format, and send them to the UI */
        setState(() {
          lastReceivedData = SensorModel(values: values);
          initialized = true;

          /* Perform additional handling here */

        });
        buf = "";
      }
  }

  void updateState(String st)
  {
    print(st);
    setState(() {
      state = st;
    });
  }

  void handleServiceDiscovered(BluetoothService service)
  {
    if(service.uuid.toString().toLowerCase() == BlueSensorAttributes.DustSensorServiceUUID)
    {
      updateState("Blue Sensor Dust Sensor found - configuring characteristic");
      var characteristics = service.characteristics;
      /* Search for the Dust Sensor characteristic */
      for(BluetoothCharacteristic c in characteristics) {
        if(c.uuid.toString().toLowerCase() == BlueSensorAttributes.DustSensorCharacteristicUUID)
        {
          updateState("Characteristic found - reading, READ flag is " + c.properties.read.toString());

          /* Enable notification */
          updateState("Enable notification");

          /* Enable notification */
          c.setNotifyValue(true).then((s) {

            /* Catch updates on characteristic  */
            c.value.listen((value) {
              _handleCharacteristicUpdate(value);
            }
            );

            /* Now we tell the sensor to start sending data by sending char 'c' (?) */
            updateState("Starting up streaming");
            c.write([0x63]).then((s) {
              print("Requested streaming start");
            });
          });
        }
      }
    }
  }

  void handleDeviceConnect(BluetoothDevice d)
  {
    updateState("Configuring device");
    List<BluetoothService> services;
    d.discoverServices().then ((s) {

      /* Discover services, and search for the Dust Sensor service */
      s.forEach((service) {
        handleServiceDiscovered(service);
      });
    });
  }

  Future<void> initializeDevice()
  async {
    print("Connecting to device");
    await widget.device.connect();

    /* Listen on connection state changes */
    var deviceStateSub = widget.device.state.listen((s) {
      if(s == BluetoothDeviceState.connected)
        {
          /* Perform device initialization */
          handleDeviceConnect(widget.device);
        } else {
        /* TODO: Handle reconnection here */
      }
    });


  }

  @override
  void initState() {
    super.initState();
    initializeDevice();
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    /* If we are not initialized, display status info */
    if(!initialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name),
        ),
        body: Center(
          child: Column(
              children: <Widget>[
                CupertinoActivityIndicator(),
                Text(state),
              ]
          ),
        ),
      );
    }
    else {
      /* We got data : display them */
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name),
        ),
        body: Center(
          child: Column(
              children: <Widget>[
                Text("PM1  : " + lastReceivedData.values[SensorModel.SENSOR_PM_1]),
                Text("PM2.5: " + lastReceivedData.values[SensorModel.SENSOR_PM_2_5]),
                Text("PM10 : " + lastReceivedData.values[SensorModel.SENSOR_PM_10]),
                Text("BAT  : " + lastReceivedData.values[SensorModel.SENSOR_VOLT]),
                Text("TEMP : " + lastReceivedData.values[SensorModel.SENSOR_TEMP]),
              ]
          ),
        ),
      );
    }
  }
}
