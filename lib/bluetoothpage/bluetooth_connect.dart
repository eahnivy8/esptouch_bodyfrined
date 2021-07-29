import 'package:esp_touch/ble/ble_device_Item.dart';
import 'package:esp_touch/ble/device_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import '../after_layout.dart';
import '../common.dart';

class BlueToothConnect extends StatefulWidget {
  @override
  _BlueToothConnectState createState() => _BlueToothConnectState();
}

class _BlueToothConnectState extends State<BlueToothConnect>
    with AfterLayoutMixin {
  BleManager _bleManager = BleManager();

  Peripheral _curPeripheral; // 연결된 장치 변수
  List<BleDeviceItem> deviceList = []; // BLE 장치 리스트 변수

  @override
  void afterFirstLayout(BuildContext context) {
    scan();
    print("scan??");
  }

  @override
  void initState() {
    super.initState();
    deviceBloc.startScan();
    _bleManager = deviceBloc.getBleManager.value;
  }

  void scan() async {
    if (deviceBloc.scanningResult.value) {
      deviceList.clear(); //기존 장치 리스트 초기화
      //SCAN 시작
      _bleManager.startPeripheralScan().listen((scanResult) {
        //listen 이벤트 형식으로 장치가 발견되면 해당 루틴을 계속 탐.
        //periphernal.name이 없으면 advertisementData.localName확인 이것도 없다면 unknown으로 표시
        var name = scanResult.peripheral.name ??
            scanResult.advertisementData.localName ??
            "Unknown";
        // 기존에 존재하는 장치면 업데이트
        var findDevice = deviceList.any((element) {
          if (element.peripheral.identifier ==
              scanResult.peripheral.identifier) {
            element.peripheral = scanResult.peripheral;
            element.advertisementData = scanResult.advertisementData;
            element.rssi = scanResult.rssi;
            return true;
          }
          return false;
        });
        // 새로 발견된 장치면 추가

        if (!findDevice) {
          deviceList.add(BleDeviceItem(name, scanResult.rssi,
              scanResult.peripheral, scanResult.advertisementData));
        }
        if (this.mounted) {
          setState(() {
            print("");
          });
        }

        if (this.mounted) {
          setState(() {
            //BLE 상태가 변경되면 화면도 갱신
          });
        }
      });
    } else {
      //스켄중이었으면 스캔 중지
      _bleManager.stopPeripheralScan();
      if (this.mounted) {
        setState(() {
          //BLE 상태가 변경되면 페이지도 갱신
        });
      }
    }
  }

  list() {
    if (deviceList.length == 0) {
      return Center(
        child: Text("연결 가능한 디바이스가 없습니다."),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(
                deviceList[index].deviceName,
                style: TextStyle(color: Colors.black),
              ),
              subtitle: Text(
                deviceList[index].peripheral.identifier,
                style: TextStyle(color: Colors.black),
              ),
              trailing: Text(
                "${deviceList[index].rssi}",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // 리스트중 한개를 탭(터치) 하면 해당 디바이스와 연결을 시도한다.
                connect(index);
              });
        },
      );
    }
  }

  _runWithErrorHandling(runFunction) async {
    try {
      await runFunction();
    } on BleError catch (e) {
      print("BleError caught: ${e.errorCode.value} ${e.reason}");
    } catch (e) {
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      print("${e.runtimeType}: $e");
    }
  }

  connect(index) async {
    if (deviceBloc.peripheral.value != null) {
      //이미 연결상태면 연결 해제후 종료
      await _curPeripheral?.disconnectOrCancelConnection();
      return;
    }

    //선택한 장치의 peripheral 값을 가져온다.
    Peripheral peripheral = deviceList[index].peripheral;

    //해당 장치와의 연결상태를 관촬하는 리스너 실행
    peripheral
        .observeConnectionState(emitCurrentValue: true)
        .listen((connectionState) {
      // 연결상태가 변경되면 해당 루틴을 탐.
      switch (connectionState) {
        case PeripheralConnectionState.connected:
          {
            //연결됨
            _curPeripheral = peripheral;
            common.showToast("연결되었습니다");
          }
          break;
        case PeripheralConnectionState.connecting:
          {
            common.showToast("장치 연결중입니다");
          } //연결중
          break;
        case PeripheralConnectionState.disconnected:
          {
            //해제됨
            print("${peripheral.name} has DISCONNECTED");
            common.showToast("장치가 해제 되었습니다.");
          }
          break;
        case PeripheralConnectionState.disconnecting:
          {} //해제중
          break;
        default:
          {
            //알수없음...
            print("unkown connection state is: \n $connectionState");
          }
          break;
      }
    });

    _runWithErrorHandling(() async {
      //해당 장치와 이미 연결되어 있는지 확인
      bool isConnected = await peripheral.isConnected();
      if (isConnected) {
        print('device is already connected');
        return;
      }

      //연결 시작!
      await peripheral.connect().then((_) {
        //연결이 되면 장치의 모든 서비스와 캐릭터리스틱을 검색한다.
        peripheral
            .discoverAllServicesAndCharacteristics()
            .then((_) => peripheral.services())
            .then((services) async {
          print("PRINTING SERVICES for ${peripheral.name}");
          //각각의 서비스의 하위 캐릭터리스틱 정보를 디버깅창에 표시한다.
          for (var service in services) {
            print("Found service ${service.uuid}");
            List<Characteristic> characteristics =
                await service.characteristics();
            for (var characteristic in characteristics) {
              print("${characteristic.uuid}");
            }
          }
          //모든 과정이 마무리되면 연결되었다고 표시
          //deviceBloc.connect();
          deviceBloc.stopScan();
          print(peripheral.identifier);
          print("${peripheral.name} has CONNECTED");
          print("연결완료1");
          deviceBloc.saveInfo(peripheral);
          print("연결완료2");
          deviceBloc.receiveMsg(
            deviceBloc.peripheral.value,
            "0000FFF0-0000-1000-8000-00805F9B34FB",
            "0734594A-A8E7-4B1A-A6B1-CD5243059A57",
          );
          print("연결완료3");
          Navigator.of(context).pop();
        });
      });
    });
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool bluetoothUsing = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text("블루투스"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  deviceBloc.peripheral.value != null
                      ? Container(
                          child: ListTile(
                              title: Text(
                                deviceBloc.peripheral.value.name,
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                deviceBloc.peripheral.value.identifier,
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: Text("연결됨",style: TextStyle(color: Colors.blue),),
                              onTap: () {
                                // 리스트중 한개를 탭(터치) 하면 해당 디바이스와 연결을 시도한다.
                              }),
                        )
                      : Container(),
                  Container(
                      color: Colors.blue,
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "연결가능한 디바이스",style: TextStyle(
                          color: Colors.white
                        ),
                        ),
                      )),
                  Expanded(
                    flex: 2,
                    child: list(),
                  ),
                ],
              )),
              deviceBloc.peripheral.value != null
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          deviceBloc.peripheral.value
                              .disconnectOrCancelConnection();
                          deviceBloc.removePeripheral();
                          deviceBloc.deleteBleData();
                        });
                      },
                      child: Container(
                        color: Colors.black,
                        height: 75,
                        child: Center(
                          child: Text("연결해제",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20),),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      onWillPop: () async => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('페이지를 나가시겠습니까?'),
                  actions: <Widget>[
                    RaisedButton(
                        child: Text('확인'),
                        onPressed: () => Navigator.of(context).pop(true)),
                    RaisedButton(
                        child: Text('취소'),
                        onPressed: () => Navigator.of(context).pop(false)),
                  ])),
    );
  }
}
