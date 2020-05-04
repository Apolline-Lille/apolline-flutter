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

  Future<void> initializeDevice()
  async {
    print("Connecting to device");
    await widget.device.connect();

    /* TODO: check the appropriate service is discovered here */
    //
    updateState("Configuring device");
    List<BluetoothService> services = await widget.device.discoverServices();

    /* Discover services, and search for the Dust Sensor service */
    services.forEach((service) async {
      if(service.uuid.toString().toLowerCase() == BlueSensorAttributes.DustSensorServiceUUID)
        {
          updateState("Blue Sensor Dust Sensor found - configuring characteristic");
          var characteristics = service.characteristics;
          /* Search for the Dust Sensor characteristic */
          for(BluetoothCharacteristic c in characteristics) {
            if(c.uuid.toString().toLowerCase() == BlueSensorAttributes.DustSensorCharacteristicUUID)
              {
                /* Read the characteristic
                TODO: this has been commented as it crashes the process.
                But it seems to be required to initialize correctly the device...
                 */
                updateState("Characteristic found - reading");
                //List<int> value = await c.read();

                updateState("Enable notification");
                /* Enable notification */
                await c.setNotifyValue(true);

                /* Catch updates */
                c.value.listen((value) {
                    _handleCharacteristicUpdate(value);
                  }
                );

                updateState("Telling sensor to start sending data");
                var descriptors = c.descriptors;
                for(BluetoothDescriptor d in descriptors) {
                  if(d.uuid.toString().toLowerCase() == BlueSensorAttributes.CLIENT_CHARACTERISTIC_CONFIG)
                    {
                      /* Write ENABLE_NOTIFICATION value */
                      /* TODO: on iOS, this crashes as iOS is expecting another API call designed for this purposes, which FlutterBlue does not use */
                      await d.write([0x01, 0x00]);
                    }
                }

                /* Now we tell the sensor to start sending data by sending char 'c', but this won't work if we haven't read the characteristic previously. */
                updateState("Starting up streaming");
                await c.write([0x63]);

              }

          }
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
