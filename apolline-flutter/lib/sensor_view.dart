import 'dart:async';
import 'dart:io';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/twins/SensorTwin.dart';
import 'package:apollineflutter/twins/SensorTwinEvent.dart';
import 'package:apollineflutter/utils/device_connection_status.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';
import 'package:apollineflutter/utils/sensor_events/events_dialog.dart';
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
  SensorView({required Key key, required this.device}) : super(key: key);
  final BluetoothDevice device;
  final UserConfigurationService ucS = locator<UserConfigurationService>();
  final AndroidNotificationDetails androidPlatformWarningChannelSpecifics =
    AndroidNotificationDetails(
        'apolline_exposure_warning_notifications',
        'notifications.warningChannel.name'.tr(),
        'notifications.warningChannel.description'.tr(),
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true
    );
  final AndroidNotificationDetails androidPlatformDangerChannelSpecifics =
    AndroidNotificationDetails(
        'apolline_exposure_danger_notifications',
        'notifications.dangerChannel.name'.tr(),
        'notifications.dangerChannel.description'.tr(),
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true
    );


  @override
  State<StatefulWidget> createState() => _SensorViewState();
}


class _SensorViewState extends State<SensorView> {
  String state = "connectionMessages.connecting".tr();
  DataPointModel? lastReceivedData;
  bool isConnected = false;
  ConnexionType connectType = ConnexionType.Normal;
  late SensorTwin _sensor;
  Map<bool, int> _notificationTimestamps = Map();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _receivedData = false;
  late Timer timer;


  @override
  void initState() {
    super.initState();
    initializeDevice();
    timer = Timer.periodic(Duration(minutes: 5), (timer) {
      widget.ucS.userConf.clearSensorEvents(widget.device.name);
      widget.ucS.update();
    });
  }


  ///
  ///
  Future<void> initializeDevice() async {
    print("Connecting to device");
    bool isConnectedToDevice = true;

    try {
      await widget.device.connect().timeout(Duration(seconds: 8), onTimeout: () {
        isConnectedToDevice = false;
        if (_scaffoldMessengerKey.currentContext != null) {
          Fluttertoast.showToast(msg: "connectionMessages.failed".tr());
          this._onWillPop(DeviceConnectionStatus.UNABLE_TO_CONNECT);
        }
      });
    } catch (e) {
      if (e != "already_connected") {
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
    if (Platform.isAndroid && await FlutterBackground.hasPermissions)
      FlutterBackground.enableBackgroundExecution();
  }

  void disableBackgroundExecution () {
    if (Platform.isAndroid && FlutterBackground.isBackgroundExecutionEnabled)
      FlutterBackground.disableBackgroundExecution();
  }

  void _onLiveDataReceived (DataPointModel model) {
    widget.ucS.userConf.addSensorEvent(widget.device.name, SensorEventType.LiveData);
    widget.ucS.update();

    setState(() {
      lastReceivedData = model;
      this._receivedData = true;
    });

    Future.delayed(Duration(milliseconds: 150), () {
      setState(() {
        this._receivedData = false;
      });
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
          "notifications.warning.title".tr(args: [value.getLabelKey().tr()]),
          'notifications.warning.body'.tr(args: [collectedValue.toString()]),
          false
        );
      } else if (widget.ucS.userConf.showDangerNotifications && collectedValue >= dangerThreshold) {
        // print("[DANGER] $value concentration is $collectedValue (>= $dangerThreshold).");
        _checkNotification(
          "notifications.danger.title".tr(args: [value.getLabelKey().tr()]),
          'notifications.danger.body'.tr(args: [collectedValue.toString()]),
          true
        );
      }
    });
  }

  void _onSensorConnected () {
    widget.ucS.userConf.addSensorEvent(widget.device.name, SensorEventType.Connection);
    widget.ucS.update();

    if (connectType == ConnexionType.Disconnect && !isConnected) {
      print("-------------------connectedExécute---------");
      handleDeviceConnect(widget.device);
    } else {
      print("--------------------connected--------------");
      showSnackBar("connectionMessages.connected".tr());
    }
  }

  void _onSensorDisconnected () {
    widget.ucS.userConf.addSensorEvent(widget.device.name, SensorEventType.Disconnection);
    widget.ucS.update();

    print("----------------disconnected----------------");
    setState(() {
      isConnected = false;
    });
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
    ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext!)?.hideCurrentSnackBar();
    ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext!)?.showSnackBar(snackBar);
  }

  Future<void> _checkNotification (String title, String message, bool isDanger) async {
    if (!_notificationTimestamps.containsKey(isDanger)) {
      _showNotification( title, message, isDanger: isDanger );
      _notificationTimestamps[isDanger] = DateTime.now().millisecondsSinceEpoch;
    }
    if (DateTime.now().millisecondsSinceEpoch - _notificationTimestamps[isDanger]! > widget.ucS.userConf.exposureNotificationsTimeInterval.inMilliseconds) {
      _showNotification( title, message, isDanger: isDanger );
      _notificationTimestamps[isDanger] = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> _showNotification (String title, String message, {bool isDanger = false}) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: isDanger
          ? widget.androidPlatformDangerChannelSpecifics
          : widget.androidPlatformWarningChannelSpecifics
    );
    await FlutterLocalNotificationsPlugin().show(
        isDanger ? -1 : -2,
        title, message, platformChannelSpecifics
    );
  }


  @override
  void dispose() {
    FlutterLocalNotificationsPlugin().cancelAll();
    widget.device.disconnect();
    this._sensor.shutdown();
    disableBackgroundExecution();
    this.timer.cancel();
    super.dispose();
  }


  ///
  ///Called when press back button
  Future<bool> _onWillPop(DeviceConnectionStatus status) async {
    if (_scaffoldMessengerKey.currentContext != null) {
      ScaffoldMessenger.maybeOf(_scaffoldMessengerKey.currentContext!)?.hideCurrentSnackBar();
      Navigator.pop(context, status);
    }

    disableBackgroundExecution();
    return false;
  }

  Widget _getActionIndicator() {
    return _sensor != null
        ? Container(
          margin: EdgeInsets.only(right: 15),
          child: IconButton(
              onPressed: () => showSensorEventsDialog(context, widget.device.name),
              icon: Icon(
                Icons.circle_sharp,
                color: !this.isConnected
                    ? Colors.red
                    : this._receivedData
                    ? Colors.green.shade800
                    : Colors.green.shade900,
              ))
        )
        : Container();
  }

  /* UI update only */
  @override
  Widget build(BuildContext context) {
    bool hasData = lastReceivedData != null;
    final ThemeData theme = Theme.of(context);
    final Duration animationDuration = const Duration(milliseconds: 500);

    return WillPopScope(
        onWillPop: () => _onWillPop(DeviceConnectionStatusHelper.fromConnectionStatus(isConnected)),
        child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldMessengerKey,
          bottomNavigationBar: IgnorePointer(
            ignoring: !hasData,
            child: ColorFiltered(
              colorFilter: hasData ? ColorFilter.mode(Colors.transparent, BlendMode.exclusion) : ColorFilter.mode(Colors.grey.shade500, BlendMode.modulate),
              child: Container(
                color: theme.primaryColor,
                child: TabBar(
                  automaticIndicatorColorAdjustment: true,
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: "navigation.home".tr()),
                    Tab(icon: Icon(Icons.insert_chart), text: "navigation.chart".tr()),
                    Tab(icon: Icon(Icons.map), text: "navigation.map".tr())
                  ],
                ),
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(_sensor != null ? _sensor.name : "connectionMessages.connecting".tr()),
            actions: [
              this._getActionIndicator()
            ],
          ),
          body: Stack(
            children: [
              AnimatedOpacity(
                opacity: hasData ? 0.0 : 1.0,
                duration: animationDuration,
                child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container (
                            child: CupertinoActivityIndicator(),
                            margin: EdgeInsets.only(bottom: 10)
                        ),
                        Text(state),
                      ]
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: hasData ? 1.0 : 0.0,
                duration: animationDuration,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Quality(key: super.widget.key!, lastReceivedData: lastReceivedData),
                    Stats(key: super.widget.key!),
                    PMMapView()
                  ]
                ),
              )
            ]),
          )
        )
    );
  }
}
