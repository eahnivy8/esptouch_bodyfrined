import 'dart:typed_data';
import 'package:esp_touch/barcode/barcode_bloc.dart';

import '../common.dart';
import 'device_bloc.dart';

class BleController {
  sendData(String sendCode) {
    if(deviceBloc.peripheral.value == null) {
      common.showToast("블루투스를 연결 되어 있지않습니다");
      return false;
    } else {
      // List data = sendCode.split('');
      List<int> intData = [];
      intData.add(0xFF);
      intData.add(0x55);
      // for(int i =0; i<data.length; i++){
      //   //intData.add(int.parse(data[i]));
      //   intData.add(data[i].hashCode);
      // }
      intData.addAll(sendCode.codeUnits);
      barcodeBloc.saveBarcode(intData);


      Uint8List uint8list = Uint8List.fromList(intData);
      deviceBloc.peripheral.value
          .writeCharacteristic(key1, key3, uint8list, false);
      return true;
    }
  }
}

final bleController = BleController();
const String key1 = "0000FFF0-0000-1000-8000-00805F9B34FB";
const String key3 = "0000FFF1-0000-1000-8000-00805F9B34FB";