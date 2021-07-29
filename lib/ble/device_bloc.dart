import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:esp_touch/barcode/barcode_bloc.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:rxdart/rxdart.dart';

import '../common.dart';

class DeviceBloc {
  final BehaviorSubject<Peripheral> _peripheralSubject =
      BehaviorSubject<Peripheral>();

  final BehaviorSubject<bool> scanning = BehaviorSubject<bool>();

  final BehaviorSubject<dynamic> bleData = BehaviorSubject<dynamic>();
  final BehaviorSubject<BleManager> bleManagerState =
      BehaviorSubject<BleManager>();

  Stream<CharacteristicWithValue> characteristicUpdates;
  var resultByte = new List();

  saveBleManager(BleManager bleManager) {
    bleManagerState.sink.add(bleManager);
  }

  BehaviorSubject<BleManager> get getBleManager {
    return bleManagerState;
  }

  dispose() {
    _peripheralSubject.close();
    scanning.close();
    bleData.close();
    bleManagerState.close();
  }

  saveInfo(Peripheral peripheral) {
    _peripheralSubject.sink.add(peripheral);
  }

  removePeripheral() {
    _peripheralSubject.value = null;
  }

  BehaviorSubject<Peripheral> get peripheral {
    return _peripheralSubject;
  }

  stopScan() {
    scanning.value = false;
  }

  startScan() {
    scanning.value = true;
  }

  BehaviorSubject<bool> get scanningResult {
    return scanning;
  }

  deleteBleData() {
    bleData.value = null;
  }

  saveBleData(List<dynamic> byteTest) {
    bleData.sink.add(byteTest);
  }

  receiveMsg(Peripheral peripheral, String BLE_SERVICE_UUID,
      String BLE_TX_CHARACTERISTIC) async {
    characteristicUpdates = peripheral.monitorCharacteristic(
        BLE_SERVICE_UUID, BLE_TX_CHARACTERISTIC);
    print("리시브 메시지 도달");
    //데이터 받는 리스너 핸들 변수
    StreamSubscription monitoringStreamSubscription;

    //이미 리스너가 있다면 취소
    await monitoringStreamSubscription?.cancel(); // ?. = 해당객체가 null이면 무시하고 넘어감.

    monitoringStreamSubscription = characteristicUpdates.listen(
      (value) {
        print("data : ${value.value}");
        checkReceiveAndBarcode(value.value);
      },
      onError: (error) {
        print("Error while monitoring characteristic \n$error"); //실패시
        deviceBloc.removePeripheral();
        deviceBloc.deleteBleData();
      },
      cancelOnError: true, //// 에러 발생시 자동으로 listen 취소
    );
  }

  int firstElement = 85;
  int secondElement = 170;
  bool readyGetByte = false;
  var temp = new List();

  checkReceiveAndBarcode(Uint8List value) {
    bool check = true;
    print(barcodeBloc.barcodeResult.value);
    for(int i =0; i < value.length; i++) {
      if( value[i] == barcodeBloc.barcodeResult.value[i]) {
        check = true;
      } else {
        check = false;
        common.showToast("실패");
        return;
      }
    }
    if(check)common.showToast("성공");
  }
}

final deviceBloc = DeviceBloc();
