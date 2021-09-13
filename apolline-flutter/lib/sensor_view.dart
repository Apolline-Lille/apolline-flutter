import 'dart:async';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/twins/SensorTwin.dart';
import 'package:apollineflutter/twins/SensorTwinEvent.dart';
import 'package:apollineflutter/utils/device_connection_status.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/data_point_model.dart';
import 'widgets/maps.dart';
import 'widgets/quality.dart';
import 'widgets/stats.dart';
import 'package:easy_localization/easy_localization.dart';


enum ConnexionType { Normal, Disconnect }


class SensorView extends StatefulWidget {
  SensorView({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;
  final UserConfigurationService ucS = locator<UserConfigurationService>();
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'apolline_exposure_notifications',
        'Exposure notifications',
        'Get alerts when current PM values are above warning/danger thresholds.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false
    );

  @override
  State<StatefulWidget> createState() => _SensorViewState();
}


class _SensorViewState extends State<SensorView> {
  String state = "connectionMessages.connecting".tr();
  DataPointModel lastReceivedData;
  bool isConnected = false;
  ConnexionType connectType = ConnexionType.Normal;
  SensorTwin _sensor;
  Map<PMFilter, int> _notificationTimestamps = Map();
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
          Fluttertoast.showToast(msg: "connectionMessages.failed".tr());
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

    updateState("connectionMessages.configuring".tr());
    this._sensor = SensorTwin(device: device, syncTiming: Duration(minutes: 2));
    this._sensor.on(SensorTwinEvent.live_data, (d) => _onLiveDataReceived(d as DataPointModel));
    this._sensor.on(SensorTwinEvent.sensor_connected, (_) => _onSensorConnected());
    this._sensor.on(SensorTwinEvent.sensor_disconnected, (_) => _onSensorDisconnected());
    bool initResult = await this._sensor.init();
    if (!initResult) {
      Fluttertoast.showToast(msg: "connectionMessages.incompatible".tr());
      this._onWillPop(DeviceConnectionStatus.INCOMPATIBLE);
      return;
    }
    await this._sensor.launchDataLiveTransmission();
    updateState("connectionMessages.waiting".tr());
    activateBackgroundExecution();
  }

  void activateBackgroundExecution () async {
    if (await FlutterBackground.hasPermissions)
      FlutterBackground.enableBackgroundExecution();
  }

  void disableBackgroundExecution () {
    if (FlutterBackground.isBackgroundExecutionEnabled)
      FlutterBackground.disableBackgroundExecution();
  }

  void _onLiveDataReceived (DataPointModel model) {
    setState(() {
      lastReceivedData = model;
    });

    if (!widget.ucS.userConf.showDangerNotifications && !widget.ucS.userConf.showWarningNotifications) return;
    PMFilter.values.forEach((value) {
      double collectedValue = double.parse(model.values[value.getRowIndex()]);
      List<int> userThresholds = widget.ucS.userConf.getThresholds(value);
      int warningThreshold = userThresholds[0];
      int dangerThreshold = userThresholds[1];

      if (widget.ucS.userConf.showWarningNotifications && collectedValue < dangerThreshold && collectedValue >= warningThreshold) {
        // print("[WARNING] $value concentration is $collectedValue (>= $warningThreshold).");
        _checkNotification(
          "Warning",
          '"${value.getLabelKey().tr()}" value exceeds warning threshold.',
          value
        );
      } else if (widget.ucS.userConf.showDangerNotifications && collectedValue >= dangerThreshold) {
        // print("[DANGER] $value concentration is $collectedValue (>= $dangerThreshold).");
        _checkNotification(
          "Danger",
          '"${value.getLabelKey().tr()}" value exceeds danger threshold.',
          value
        );
      }
    });
  }

  void _onSensorConnected () {
    if (connectType == ConnexionType.Disconnect && !isConnected) {
      print("-------------------connectedExécute---------");
      handleDeviceConnect(widget.device);
    } else {
      print("--------------------connected--------------");
      showSnackBar("connectionMessages.connected".tr());
    }
  }

  void _onSensorDisconnected () {
    print("----------------disconnected----------------");
    isConnected = false;
    connectType = ConnexionType.Disconnect; //deconnexion
    showSnackBar("connectionMessages.disconnected".tr(), duration: Duration(days: 1));
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

  Future<void> _checkNotification (String title, String message, PMFilter filter) async {
    if (!_notificationTimestamps.containsKey(filter)) {
      _notificationTimestamps[filter] = DateTime.now().millisecondsSinceEpoch;
    }
    if (DateTime.now().millisecondsSinceEpoch - _notificationTimestamps[filter] > widget.ucS.userConf.exposureNotificationsTimeInterval.inMilliseconds) {
      _showNotification( title, message );
      _notificationTimestamps[filter] = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> _showNotification (String title, String message) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: widget.androidPlatformChannelSpecifics
    );
    await FlutterLocalNotificationsPlugin().show(
        0, title, message, platformChannelSpecifics
    );
  }


  @override
  void dispose() {
    widget.device.disconnect();
    this._sensor?.shutdown();
    disableBackgroundExecution();
    super.dispose();
  }


  ///
  ///Called when press back button
  Future<bool> _onWillPop(DeviceConnectionStatus status) async {
    if (_scaffoldMessengerKey.currentContext != null) {
      ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext).hideCurrentSnackBar();
      Navigator.pop(context, status);
    }

    disableBackgroundExecution();
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
          title: Text(_sensor != null ? _sensor.name : "connectionMessages.connecting".tr()),
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
                title: Text(_sensor != null ? _sensor.name : "connectionMessages.connecting".tr()),
              ),
              body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
                Quality(lastReceivedData: lastReceivedData),
                Stats(),
                PMMapView()
              ])),
        ),
      );
    }
  }
}
