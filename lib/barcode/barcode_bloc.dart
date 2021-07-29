import 'package:rxdart/rxdart.dart';

class BarcodeBloc {
  final BehaviorSubject<List<int>> _barcodValue =
  BehaviorSubject<List<int>>();

  dispose() {
    _barcodValue.close();
  }
  
  saveBarcode(List<int> intData){
    _barcodValue.sink.add(intData);
  }

  BehaviorSubject<List<int>> get barcodeResult {
    return _barcodValue;
  }
}

final barcodeBloc = BarcodeBloc();