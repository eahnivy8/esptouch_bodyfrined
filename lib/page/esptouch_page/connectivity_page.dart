import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:esp_touch/page/esptouch_page/wifi_page.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart' as ble;
import 'package:permission_handler/permission_handler.dart';

import '../../after_layout.dart';
import '../../ble/ble_controller.dart';
import '../../ble/device_bloc.dart';
import '../../bluetoothpage/bluetooth_connect.dart';

class ConnectivityPage extends StatefulWidget {
  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  Connectivity _connectivity;
  Stream<ConnectivityResult> _connectivityStream;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult result;
  String _scanBarcode = 'Unknown';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((e) {
      setState(() {});
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Esp-Touch"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder(
          future: _connectivity.checkConnectivity(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else if (snapshot.data == ConnectivityResult.wifi) {
              return FutureBuilder<Map<String, String>>(
                  future: EsptouchSmartconfig.wifiData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: WifiPage(snapshot.data['wifiName'],
                                snapshot.data['bssid']),
                          ),
                        ],
                      );
                    } else
                      return Container();
                  });
            } else
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_sharp,
                      size: 200,
                      color: Colors.red,
                    ),
                    Text(
                      "와이파이를 연결해주세요",
                      style: TextStyle(fontSize: 40, color: Colors.red),
                    )
                  ],
                ),
              );
          }),
    );
  }
}
