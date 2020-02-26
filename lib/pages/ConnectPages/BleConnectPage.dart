import 'dart:ffi';

import 'package:dhsjakd/DB/paw_db/paw_db.dart';
import 'package:dhsjakd/utls/EventBus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dhsjakd/alerts/GetPaw1Alert.dart';
import 'package:dhsjakd/alerts/SconningAlert.dart';
import 'package:dhsjakd/ble__manager/BLECentralManager.dart';
import 'package:dhsjakd/ble__manager/BLEPeripheral.dart';

import 'BleConnectIO.dart';

// import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';

class BleConnectPage extends StatefulWidget {
  final arguments;
  BleConnectPage({Key key, this.arguments}) : super(key: key);

  @override
  _BleConnectPageState createState() => _BleConnectPageState();
}

class _BleConnectPageState extends State<BleConnectPage> {
  //控制界面
  bool _isTryConnected = false;
  BLEPeripheral _selectedPeripheral;
  BleConnectIO connectIO;

  //连接后加载完成。
  ValueGetter connectLoadedEndBlock = this.aaa();

  @override
  void initState() {
    super.initState();

    //初始化数据库表
    PawDB.internal().init();

    // bool isconect = await BLECentralManager().connectPeripheral(peripherals[index]);
    //           if (isconect) {
    //             Navigator.pushNamed(context, '/bleConnected',arguments: {"peripheral":BLECentralManager().connectedPeripheral});
    //           }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: AlignmentDirectional.center,
      color: Color(0xFF131313),
      child: getWidget(context),
    ));
  }

  Widget getWidget(BuildContext context) {
    Widget widget;
    if (!this._isTryConnected) {
      widget = getFirstView(context);
    } else {
      widget = getSecondView(context);
    }
    return widget;
  }

  Widget getFirstView(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Positioned(top: 39, child: first_titleText(context)),
        Positioned(bottom: 192, child: first_descText(context)),
        Positioned(bottom: 96, child: first_scanDeviceButton(context)),
        Positioned(bottom: 36, child: first_getPAW1Button(context)),
      ],
    );
  }

  Widget getSecondView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 36)),
        Container(
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                decoration: ShapeDecoration(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(250.0)),
                  ),
                ),
                width: 450,
                height: 450,
                child: Center(
                  child: Text("图片"),
                ),
              ),
              Positioned(bottom: 20, child: second_titleText(context)),
              Positioned(bottom: -20, child: second_descText(context)),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 80)),
        Container(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            second_notFindDeviceButton(context),
            second_scanDeviceButton(context)
          ],
        )),
        Padding(padding: EdgeInsets.only(top: 44)),
      ],
    );
  }

  Widget getThirdView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 229)),
        third_titleText(context),
        Padding(padding: EdgeInsets.only(top: 21)),
        third_descText(context),
        Padding(padding: EdgeInsets.only(top: 198)),
        third_scanDeviceButton(context),
        Padding(padding: EdgeInsets.only(top: 27)),
        third_bottomDescText(context),
        Padding(padding: EdgeInsets.only(top: 44)),
      ],
    );
  }

// 逻辑页面处理 ------- -------------
  void setupIsTryConnect(bool isTryConnect) {
    this._isTryConnected = isTryConnect;
    setState(() {});
  }

//连接选择的设备
  void setSelectedPeripheral(BLEPeripheral peripheral) async {
    this._selectedPeripheral = peripheral;
    setupIsTryConnect(true);
    BLECentralManager().connectPeripheral(this._selectedPeripheral,
        (isConnect) {
      if (isConnect as bool) {
        print("${BLECentralManager().connectedPeripheral.name}");
        this.connectIO = BleConnectIO()
          ..getDeviceState()
          ..loadedEndBlock = this.connectLoadedEndBlock;
      } else {
        print(isConnect);
      }
    });
  }

  void startScanningDevice(BuildContext context) {
    BLECentralManager().startScanning(isAutoConnect: true);
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            //创建dialog
            return SconningAlert(
              onCloseEvent: () {
                Navigator.pop(context);
              },
              onPositivePressEvent: (BLEPeripheral peripheral) {
                setSelectedPeripheral(peripheral);
                Navigator.pop(context);
              },
            );
          });
        });
  }

  aaa () {
    eventBus.on<PawHeartbeatEvent>().listen((event) async {
        if (event.isChange) {
          
        }
    });
  }

// 组件 ----------
  // "连接设备" text
  Widget first_titleText(BuildContext context) {
    return Text(
      "连接设备",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w500,
          color: Color(0xFFF6F7FB),
          fontSize: 24.0,
          wordSpacing: 2.57,
          height: 33.0 / 24.0),
    );
  }

  // "通过 Bluetooth 连接到录音笔" text
  Widget first_descText(BuildContext context) {
    return Text(
      "通过 Bluetooth 连接到录音笔",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w400,
          color: Color(0xFFF6F7FB),
          fontSize: 18.0,
          wordSpacing: 1.93,
          height: 25.0 / 18.0),
    );
  }

  // 开始扫描设备 button
  Widget first_scanDeviceButton(BuildContext context) {
    return Container(
      height: 39.0,
      width: 279,
      child: RaisedButton(
          child: Text(
            "绑定您的PAW 1",
            style: TextStyle(
                fontFamily: "PuHuiTi",
                fontWeight: FontWeight.w500,
                color: Color(0xFF212124),
                fontSize: 18.0,
                wordSpacing: 1,
                height: 25.0 / 18.0),
          ),
          color: Color(0xFF00FF8E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onPressed: () {
            //开始扫描
            startScanningDevice(context);
          }),
    );
  }

  // 去天猫淘宝京东 买录音笔Button
  Widget first_getPAW1Button(BuildContext context) {
    return Container(
      height: 39.0,
      width: 279,
      child: RaisedButton(
          child: Text(
            "获得PAW 1",
            style: TextStyle(
                fontFamily: "PuHuiTi",
                fontWeight: FontWeight.w500,
                color: Color(0xFFF6F7FB),
                fontSize: 18.0,
                wordSpacing: 1,
                height: 25.0 / 18.0),
          ),
          color: Color(0xFF2C2C31),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onPressed: () {
            //去买设备
            showDialog(
                // barrierDismissible: false,
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, state) {
                    //创建dialog
                    return GetPaw1Alert(
                      onJDEvent: () {
                        Navigator.pop(context);
                      },
                      onTmallEvent: () {
                        Navigator.pop(context);
                      },
                      onCloseEvent: () {
                        Navigator.pop(context);
                      },
                    );
                  });
                });
          }),
    );
  }

  // 第二屏--------------
  //贴近手机 text
  Widget second_titleText(BuildContext context) {
    return Text(
      "请将PAW 1 贴近手机",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w500,
          color: Color(0xFFF6F7FB),
          fontSize: 18.0,
          wordSpacing: 1.93,
          height: 25.0 / 18.0),
    );
  }

  //描述 text
  Widget second_descText(BuildContext context) {
    return Text(
      "···正在搜索···",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w500,
          color: Color(0xFFF6F7FB),
          fontSize: 18.0,
          wordSpacing: 1.93,
          height: 25.0 / 18.0),
    );
  }

  //没发现设备重新寻找
  Widget second_notFindDeviceButton(BuildContext context) {
    return FlatButton(
      child: Text(
        "没有发现设备？   |",
        style: TextStyle(
            fontFamily: "PuHuiTi",
            fontWeight: FontWeight.w400,
            color: Color(0xFF898A8D),
            fontSize: 18.0,
            wordSpacing: 1.93,
            height: 25.0 / 18.0),
      ),
      onPressed: () {},
    );
  }

  // 继续扫描
  Widget second_scanDeviceButton(BuildContext context) {
    return FlatButton(
      child: Text(
        "重新寻找",
        style: TextStyle(
            fontFamily: "PuHuiTi",
            fontWeight: FontWeight.w400,
            color: Color(0xFF898A8D),
            fontSize: 18.0,
            wordSpacing: 1.93,
            height: 25.0 / 18.0),
      ),
      onPressed: () {},
    );
  }

  //第三屏 -------------------
  // title Text
  Widget third_titleText(BuildContext context) {
    return Text(
      "没有发现可用的录音笔",
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w500,
          color: Color(0xFFF6F7FB),
          fontSize: 24.0,
          wordSpacing: 2.57,
          height: 33.0 / 24.0),
    );
  }

  Widget third_descText(BuildContext context) {
    return Text(
      "请确认您的录音笔已开机\n且手机蓝牙已打开",
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w400,
          color: Color(0xFF898A8D),
          fontSize: 18.0,
          wordSpacing: 1.93,
          height: 25.0 / 18.0),
    );
  }

  // 继续扫描
  Widget third_scanDeviceButton(BuildContext context) {
    return Container(
      height: 39.0,
      width: 279,
      child: RaisedButton(
          child: Text(
            "重新寻找",
            style: TextStyle(
                fontFamily: "PuHuiTi",
                fontWeight: FontWeight.w500,
                color: Color(0xFF212124),
                fontSize: 18.0,
                wordSpacing: 1,
                height: 25.0 / 18.0),
          ),
          color: Color(0xFF00FF8E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onPressed: () {
            //开始扫描
            startScanningDevice(context);
          }),
    );
  }

  Widget third_bottomDescText(BuildContext context) {
    return Text(
      "没有发现设备？",
      maxLines: 2,
      style: TextStyle(
          fontFamily: "PuHuiTi",
          fontWeight: FontWeight.w400,
          color: Color(0xFF898A8D),
          fontSize: 18.0,
          wordSpacing: 1.93,
          height: 25.0 / 18.0),
    );
  }

// 逻辑处理 ---

}
