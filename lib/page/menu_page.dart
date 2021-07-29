import 'package:esp_touch/page/esptouch_page/connectivity_page.dart';
import 'package:flutter/material.dart';

import 'ble_page/ble_barcode_scan.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BODYFRIEND",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "안마의자 설정",
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/img-chair.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ConnectivityPage(),
                              ));
                        },
                        child: Container(
                            color: Colors.red.withOpacity(0.9),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi,
                                  size: 50,
                                ),
                                Icon(
                                  Icons.cast_connected,
                                  size: 50,
                                ),
                                Text(
                                  "ESP_TOUCH",
                                  style: TextStyle(
                                      fontSize: 23, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ))),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BleSendBarcode(),
                              ));
                        },
                        child: Container(
                            color: Colors.grey.withOpacity(0.9),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                                Icon(Icons.scanner, size: 50),
                                Text(
                                  "블루투스/바코드 스캔",
                                  style: TextStyle(
                                      fontSize: 23, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ))),
                      ),
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
