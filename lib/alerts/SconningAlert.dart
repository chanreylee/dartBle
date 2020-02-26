import 'package:flutter/material.dart';
import 'package:dhsjakd/ble__manager/BLECentralManager.dart';
import 'package:dhsjakd/ble__manager/BLEPeripheral.dart';
import 'package:dhsjakd/utls/EventBus.dart';

class SconningAlert extends StatefulWidget {
  SconningAlert({
    Key key,
    @required this.onPositivePressEvent,
    @required this.onCloseEvent,
  }) : super(key: key);

  //左侧按钮点击事件（取消）
  Function onCloseEvent;
  //右侧按钮点击事件（确认）
  Function onPositivePressEvent;
  BLECentralManager centralManager = BLECentralManager();
  List<BLEPeripheral> scannedPeripherals = List<BLEPeripheral>();

  var eventBusOn;

  @override
  _SconningAlertState createState() => _SconningAlertState();
}

class _SconningAlertState extends State<SconningAlert> {
  @override
  void initState() {
    super.initState();
    widget.eventBusOn = eventBus.on<BleCentralManagerEvent>().listen((event) {
      widget.scannedPeripherals.add(event.scannedPeripheral);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: new Stack(
        overflow: Overflow.visible,
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          //白色背景
          new Container(
            decoration: ShapeDecoration(
              color: Color(0xff212124), //可以自定义一个颜色传过来
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
            height: 310,
            width: MediaQuery.of(context).size.width - 36,
            margin: EdgeInsets.only(top: 136),
            child: new Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Positioned(
                  top: 24,
                  child: Text(
                    "选择一个设备",
                    style: TextStyle(
                        fontFamily: "PuHuiTi",
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        color: Color(0xFFF6F7FB)),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 30,
                  right: 30,
                  bottom: 36,
                  child: Container(
                    child: ListView.builder(
                      itemCount: widget.scannedPeripherals.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            widget.scannedPeripherals[index].name,
                            style: TextStyle(
                                fontFamily: "PuHuiTi",
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                color: Color(0xFFF6F7FB)),
                          ),
                          trailing: Text(
                            "未连接",
                            style: TextStyle(
                                fontFamily: "PuHuiTi",
                                fontWeight: FontWeight.w500,
                                fontSize: 14.0,
                                color: Color(0xFF898A8D)),
                          ),
                          onTap: () {
                            widget.eventBusOn.cancel();
                            widget.onPositivePressEvent(
                                widget.scannedPeripherals[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),

                //中间显示的Widget
              ],
            ),
          ),
          Positioned(
            bottom: 200,
            child: RaisedButton(
              onPressed: () {
                widget.eventBusOn.cancel();
                widget.onCloseEvent();
              },
              child: Text(
                "关闭",
                style: TextStyle(
                    fontFamily: "PuHuiTi",
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    color: Color(0xFFFFFFFF)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
