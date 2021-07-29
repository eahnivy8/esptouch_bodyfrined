
import 'package:esp_touch/ble/device_bloc.dart';
import 'package:flutter/material.dart';

class BluetoothPopup {
  showOffPopupDisconnectDelete(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Color(0xff272727),
              content: Container(
                height: 150,
                width: 380,
                child: Column(
                  children: [
                    Container(
                      height: 108,
                      width: 380,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: Center(
                                  child: Text(
                                    "블루투스를 끊으시겠습니까?",
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  color: Color(0xFF373737),
                                  child: Center(
                                    child: Text(
                                      "취소",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                deviceBloc.peripheral.value
                                    .disconnectOrCancelConnection();
                                deviceBloc.deleteBleData();
                                Navigator.of(context).pop();
                              },
                              child: Container(

                                  child: Center(
                                    child: Text(
                                      "종료",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ));
        });
  }
}
