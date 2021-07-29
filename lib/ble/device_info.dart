// import 'dart:async';
// import 'dart:typed_data';
// import 'package:five_inch_remote_app/controller/ble/ble_controller.dart';
// import 'package:five_inch_remote_app/model/blemodel/send_action.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_ble_lib/flutter_ble_lib.dart';
// import 'dart:math';
//
// import 'device_bloc.dart';
//
// class DeviceInfo extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return DeviceInfoState();
//   }
// }
//
// class DeviceInfoState extends State<DeviceInfo> {
//   Stream<CharacteristicWithValue> characteristicUpdates;
//   CharacteristicWithValue characteristics1;
//   String byteCode;
//   var byteTest = new List();
//
//   @override
//   void initState() {
//     super.initState();
//     deviceBloc.receiveMsg(
//         deviceBloc.peripheral.value,
//         "0000FFF0-0000-1000-8000-00805F9B34FB",
//         "0734594A-A8E7-4B1A-A6B1-CD5243059A57");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Device Info"),
//         ),
//         body: StreamBuilder<Peripheral>(
//             stream: deviceBloc.peripheral.stream,
//             builder: (context, AsyncSnapshot<Peripheral> snapshot) {
//               if (snapshot.hasData) {
//                 return Column(
//                   children: <Widget>[
//                     Text(snapshot.data.name),
//                     Text(snapshot.data.identifier),
//                     TextButton(
//                       child: Text("power on hard"),
//                       onPressed: () {
//                         snapshot.data.writeCharacteristic(
//                             "0000FFF0-0000-1000-8000-00805F9B34FB",
//                             "0000FFF1-0000-1000-8000-00805F9B34FB",
//                             Uint8List.fromList(
//                                 [85, 170, 1, 13, 133, 4, 1, 2, 0, 1, 0, 161, 24]),
//                             false);
//                       },
//                     ),
//                     TextButton(
//                       child: Text("power off hard"),
//                       onPressed: () {
//                         snapshot.data.writeCharacteristic(
//                             "0000FFF0-0000-1000-8000-00805F9B34FB",
//                             "0000FFF1-0000-1000-8000-00805F9B34FB",
//                             Uint8List.fromList(
//                                 [85, 170, 1, 13, 134, 4, 1, 2, 0, 7, 0, 133, 106]),
//                             false);
//                       },
//                     ),
//                     TextButton(
//                       child: Text("power on"),
//                       onPressed: () {
//                         bleController.sendData(H10_KEY_POWER_ON);
//                       },
//                     ),
//                     TextButton(
//                         onPressed: () {
//                           bleController.sendData(H10_KEY_POWER_OFF);
//                         },
//                         child: Text("power oFF")),
//                     RaisedButton(
//                       child: Text("receiveTest"),
//                       onPressed: () {
//                         setState(() {
//                           // receiveMsg(
//                           //     snapshot.data,
//                           //     "0000FFF0-0000-1000-8000-00805F9B34FB",
//                           //     "0734594a-a8e7-4b1a-a6b1-cd5243059a57");
//                         });
//                       },
//                     ),
//                     Text(characteristics1.toString()),
//                   ],
//                 );
//               } else {
//                 return CircularProgressIndicator();
//               }
//             }));
//   }
// }
