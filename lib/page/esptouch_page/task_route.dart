import 'dart:async';
import 'package:esptouch_smartconfig/esp_touch_result.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';

class TaskRoute extends StatefulWidget {
  TaskRoute(
      this.ssid, this.bssid, this.password, this.deviceCount, this.isBroadcast);

  final String ssid;
  final String bssid;
  final String password;
  final String deviceCount;
  final bool isBroadcast;

  @override
  State<StatefulWidget> createState() {
    return TaskRouteState();
  }
}

class TaskRouteState extends State<TaskRoute> {
  Stream<ESPTouchResult> _stream;

  @override
  void initState() {
    _stream = EsptouchSmartconfig.run(widget.ssid, widget.bssid,
        widget.password, widget.deviceCount, widget.isBroadcast);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget waitingState(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
          SizedBox(height: 16),
          Text(
            '결과를 기다리는중입니다.',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget error(BuildContext context, String s) {
    return Center(
      child: Text(
        s,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget noneState(BuildContext context) {
    return Center(
        child: Text(
      '주변에 장치가 발견되지 않았습니다.',
      style: TextStyle(fontSize: 24, color: Colors.red),
    ));
  }

  Widget resultList(BuildContext context, ConnectionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text("연결된 리스트"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (_, index) {
              final result = _results.toList(growable: false)[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('BSSID: '),
                        Text(
                          result.bssid,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('IP: '),
                        Text(result.ip),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        if (state == ConnectionState.active)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
      ],
    );
  }

  Widget doneState(BuildContext context, ConnectionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text("연결된 리스트"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (_, index) {
              final result = _results.toList(growable: false)[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('BSSID: '),
                        Text(
                          result.bssid,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('IP: '),
                        Text(result.ip),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
            child: Center(
          child: Text(
            "완료 되었습니다.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ))
      ],
    );
  }

  final Set<ESPTouchResult> _results = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_results);
            }),
        backgroundColor: Colors.red,
        title: Text(
          '처리화면',
        ),
      ),
      body: Container(
        child: StreamBuilder<ESPTouchResult>(
          stream: _stream,
          builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
            if (snapshot.hasError) {
              return error(context, '에러 반복된 에러 발생시 문의');
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                _results.add(snapshot.data);
                return resultList(context, snapshot.connectionState);
              case ConnectionState.none:
                return noneState(context);
              case ConnectionState.done:
                _results.add(snapshot.data);
                return doneState(context, snapshot.connectionState);
              case ConnectionState.waiting:
                return waitingState(context);
            }
            return error(context, '연결 실패 반복해서 실패시 관리자 문의');
          },
        ),
      ),
    );
  }
}
