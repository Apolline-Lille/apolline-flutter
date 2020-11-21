import 'dart:async';

import 'package:apollineflutter/gattsample.dart';
import 'package:apollineflutter/sensormodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

/**for charts*/
import 'package:syncfusion_flutter_gauges/gauges.dart';

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

  /* Called when data is received from the sensor */
  void _handleCharacteristicUpdate(List<int> value) {
    String s = String.fromCharCodes(value);
    buf += s;

    if (buf.contains('\n')) {
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

  void updateState(String st) {
    print(st);
    setState(() {
      state = st;
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
          updateState("Characteristic found - reading, READ flag is " +
              c.properties.read.toString());

          /* Enable notification */
          updateState("Enable notification");

          c.setNotifyValue(true).then((s) {
            /* Catch updates on characteristic  */

            sub = c.value.listen((value) {
              _handleCharacteristicUpdate(value);
            });

            /* Now we tell the sensor to start sending data by sending char 'c' (?) */
            Timer(Duration(seconds: 3), () {
              //updateState("Starting up streaming");
              c.write([0x63]).then((s) {
                print("Requested streaming start");
              });
            });
          });
        }
      }
    }
  }

  void handleDeviceConnect(BluetoothDevice d) {
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
      widget.isConnected = true;
    } catch (e) {
      if (e.code != "already_connected") {
        throw e;
      }
      if (e.code == "already_connected") {
        widget.isConnected = true;
      }
    } finally {
      handleDeviceConnect(widget.device);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDevice();
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    /* If we are not initialized, display status info */
    if (!initialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, widget.isConnected);
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
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.device.name),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
          ),
          body:
              /**charts */
              GridView.count(
            primary: false,
            padding: const EdgeInsets.all(0),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              Container(
                child: SfRadialGauge(
                    title: GaugeTitle(text: "PM1"),
                    axes: <RadialAxis>[
                      RadialAxis(
                          interval: 10,
                          startAngle: 0,
                          endAngle: 360,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(thickness: 20),
                          pointers: <GaugePointer>[
                            RangePointer(
                                value: double.parse(lastReceivedData
                                    .values[SensorModel.SENSOR_PM_1]),
                                width: 20,
                                color: Colors.blueGrey,
                                enableAnimation: true,
                                cornerStyle: CornerStyle.bothCurve)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Column(
                                  children: <Widget>[
                                    Container(
                                        width: 50.00,
                                        height: 50.00,
                                        decoration: new BoxDecoration()),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                                      child: Container(
                                        child: Text(
                                            lastReceivedData.values[
                                                SensorModel.SENSOR_PM_1],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25)),
                                      ),
                                    )
                                  ],
                                ),
                                angle: 270,
                                positionFactor: 0.1)
                          ])
                    ]),
              ),
              Container(
                child: SfRadialGauge(
                    title: GaugeTitle(text: "PM2.5"),
                    axes: <RadialAxis>[
                      RadialAxis(
                          interval: 10,
                          startAngle: 0,
                          endAngle: 360,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(thickness: 20),
                          pointers: <GaugePointer>[
                            RangePointer(
                                value: double.parse(lastReceivedData
                                    .values[SensorModel.SENSOR_PM_2_5]),
                                width: 20,
                                color: Colors.blueGrey,
                                enableAnimation: true,
                                cornerStyle: CornerStyle.bothCurve)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Column(
                                  children: <Widget>[
                                    Container(
                                        width: 50.00,
                                        height: 50.00,
                                        decoration: new BoxDecoration()),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                                      child: Container(
                                        child: Text(
                                            lastReceivedData.values[
                                                SensorModel.SENSOR_PM_2_5],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25)),
                                      ),
                                    )
                                  ],
                                ),
                                angle: 270,
                                positionFactor: 0.1)
                          ])
                    ]),
              ),
              Container(
                child: SfRadialGauge(
                    title: GaugeTitle(text: "PM10"),
                    axes: <RadialAxis>[
                      RadialAxis(
                          interval: 10,
                          startAngle: 0,
                          endAngle: 360,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(thickness: 20),
                          pointers: <GaugePointer>[
                            RangePointer(
                                value: double.parse(lastReceivedData
                                    .values[SensorModel.SENSOR_PM_10]),
                                width: 20,
                                color: Colors.blueGrey,
                                enableAnimation: true,
                                cornerStyle: CornerStyle.bothCurve)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Column(
                                  children: <Widget>[
                                    Container(
                                        width: 50.00,
                                        height: 50.00,
                                        decoration: new BoxDecoration()),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                                      child: Container(
                                        child: Text(
                                            lastReceivedData.values[
                                                SensorModel.SENSOR_PM_10],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25)),
                                      ),
                                    )
                                  ],
                                ),
                                angle: 270,
                                positionFactor: 0.1)
                          ])
                    ]),
              ),
              Container(
                child: SfRadialGauge(
                  title: GaugeTitle(text: "BAT"),
                  axes: <RadialAxis>[
                    RadialAxis(
                        minimum: 23.5,
                        maximum: 24.5,
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: 23, endValue: 25, color: Colors.green)
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(
                              value: double.parse(lastReceivedData
                                  .values[SensorModel.SENSOR_VOLT]),
                              enableAnimation: true)
                        ]),
                  ],
                ),
              ),
              Container(
                  child: SfRadialGauge(
                      title: GaugeTitle(text: "TEMPERATURE"),
                      axes: <RadialAxis>[
                    RadialAxis(
                        interval: 10,
                        startAngle: 0,
                        endAngle: 360,
                        showTicks: false,
                        showLabels: false,
                        axisLineStyle: AxisLineStyle(thickness: 20),
                        pointers: <GaugePointer>[
                          RangePointer(
                              value: double.parse(lastReceivedData
                                  .values[SensorModel.SENSOR_TEMP]),
                              width: 20,
                              color: Color(0xFFFFCD60),
                              enableAnimation: true,
                              cornerStyle: CornerStyle.bothCurve)
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                              widget: Column(
                                children: <Widget>[
                                  Container(
                                      width: 50.00,
                                      height: 50.00,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image:
                                              ExactAssetImage('assets/sun.png'),
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Container(
                                      child: Text(
                                          lastReceivedData.values[
                                                  SensorModel.SENSOR_TEMP] +
                                              '°C',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  )
                                ],
                              ),
                              angle: 270,
                              positionFactor: 0.7,
                              verticalAlignment: GaugeAlignment.near)
                        ])
                  ]))
            ],
          ));
    }
  }
}
