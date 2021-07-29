import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:esp_touch/barcode/barcode_bloc.dart';
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

class BleSendBarcode extends StatefulWidget {
  @override
  _BleSendBarcodeState createState() => _BleSendBarcodeState();
}

class _BleSendBarcodeState extends State<BleSendBarcode> with AfterLayoutMixin {


  String _scanBarcode = '입력전';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    deviceBloc.saveBleManager(_bleManager);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  ble.BleManager _bleManager = ble.BleManager();

  init() async {
    //ble 매니저 생성
    await _bleManager
        .createClient(
            restoreStateIdentifier: "example-restore-state-identifier",
            restoreStateAction: (peripherals) {
              peripherals?.forEach((peripheral) {
                print("Restored peripheral: ${peripheral.name}");
              });
            })
        .catchError((e) => print("Couldn't create BLE client  $e"))
        .then((_) => _checkPermissions()) //매니저 생성되면 권한 확인
        .catchError((e) => print("Permission check error $e"));
  }

  _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.contacts.request().isGranted) {}
      Map<Permission, PermissionStatus> statuses =
          await [Permission.location].request();
      print(statuses[Permission.location]);
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "취소", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      if(_scanBarcode == "-1") {
        _scanBarcode = "취소됨";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("블루투스 바코드 스캔"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                        builder: (context) => BlueToothConnect(),
                      ));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty
                            .resolveWith<Color>(
                                (Set<MaterialState> states) =>
                            Colors.blue)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 30,
                        ),
                        Text(
                          "블루투스 연결페이지",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                      ],
                    )),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder(
                stream: deviceBloc.peripheral.stream,
                builder: (context,
                    AsyncSnapshot<ble.Peripheral> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("연결된 블루투스 장치 정보"),
                        Text(snapshot.data.name),
                        Text(snapshot.data.identifier),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                deviceBloc.peripheral.value
                                    .disconnectOrCancelConnection();
                                deviceBloc.removePeripheral();
                                deviceBloc.deleteBleData();
                              });
                            },
                            child: Text("연결해제"))
                      ],
                    );
                  } else {
                    return Container(
                        child: Center(
                          child: Text("블루투스 연결전",
                              style: TextStyle(fontSize: 20)),
                        ));
                  }
                }),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      scanBarcodeNormal();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty
                            .resolveWith<Color>(
                                (Set<MaterialState> states) =>
                            Colors.black)),
                    child: Text("스캐너",  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          Container(
            height: 150,
            child: Center(
              child: Text('스캔 : $_scanBarcode\n',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: deviceBloc.peripheral.stream,
          builder: (context, AsyncSnapshot<ble.Peripheral> snapshot) {
            if (snapshot.hasData) {
              if (_scanBarcode != "-1" && _scanBarcode != "입력전") {
                return InkWell(
                  onTap: () {
                    bleController.sendData(_scanBarcode);

                  },
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: 60,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "데이터 전송",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.send,
                          color: Colors.white,
                        )
                      ],
                    )),
                  ),
                );
              } else {
                return Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 60,
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "스캔을해주세요",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.send,
                        color: Colors.white,
                      )
                    ],
                  )),
                );
              }
            } else {
              return Container();
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
