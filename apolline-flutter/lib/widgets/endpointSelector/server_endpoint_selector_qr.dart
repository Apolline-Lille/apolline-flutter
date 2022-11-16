import 'dart:convert';
import 'dart:io';

import 'package:apollineflutter/models/server_endpoint_handler.dart';
import 'package:apollineflutter/models/server_model.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ServerEndpointSelectorQr extends StatefulWidget {
  const ServerEndpointSelectorQr({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ServerEndpointSelectorQrView();
  }

}

class ServerEndpointSelectorQrView extends State<ServerEndpointSelectorQr> {
  Barcode? result;
  QRViewController? qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("endpointQRScanner.title".tr())
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    _onQRCodeScanned()
                  else
                    Text('endpointQRScanner.title'.tr()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                            onPressed: () async {
                              await qrController?.toggleFlash();
                              setState(() {});
                            },
                            color: Theme.of(context).primaryColor,
                            icon: FutureBuilder(
                              future: qrController?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if(snapshot.hasData) {
                                  if (snapshot.data!) {
                                    return Icon(Icons.flash_on_outlined);
                                  } else {
                                    return Icon(Icons.flash_off_outlined);
                                  }
                                }
                                else if (snapshot.hasError){
                                  return Icon(Icons.flash_off_outlined);
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            )
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          onPressed: () async {
                            await qrController?.flipCamera();
                            setState(() {});
                          },
                          icon: FutureBuilder(
                            future: qrController?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData) {
                                if (snapshot.data == CameraFacing.back) {
                                  return Icon(Icons.camera_alt_rounded);
                                } else {
                                  return Icon(Icons.camera_front_rounded);
                                }
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.qrController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        qrController!.pauseCamera();
        _addEndpoint();
        qrController!.resumeCamera();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('endpointQRScanner.permissionRequired'.tr())),
      );
    }
  }

  Widget _onQRCodeScanned() {
    if(result!.format == BarcodeFormat.qrcode) {
      return CircularProgressIndicator(
          semanticsLabel: "Connection to new endpoint");
    } else {
      return Text("endpointQRScanner.codeTypeError".tr());
    }
  }

  _addEndpoint() {
    dynamic qrCodeContent;
    try {
      qrCodeContent = json.decode(result!.code!);

      if(qrCodeContent is Map<String, dynamic>) {
        ServerModel server = ServerModel.fromJson(qrCodeContent);
        SqfLiteService().addServerEndpoint(server);
        ServerEndpointHandler().changeCurrentServerEndpoint(server);
        Navigator.pop<String>(
            context, "endpoint.configAddConfirm".tr(args: [server.dbName]));
      } else {
        SnackBar snackBar = SnackBar(content: Text("endpointQRScanner.codeDataError".tr()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FormatException catch (_) {
      SnackBar snackBar = SnackBar(content: Text("endpointQRScanner.codeDataError".tr()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // see https://pub.dev/packages/qr_code_scanner
  @override
  void reassemble() {
    super.reassemble();
    if(Platform.isAndroid) {
      qrController?.pauseCamera();
    }
    qrController?.resumeCamera();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }
}