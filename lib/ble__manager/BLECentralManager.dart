import 'dart:core';
import 'package:dhsjakd/DB/PAWDevice.dart';
import 'package:dhsjakd/ble__manager/BLEHeartbeatPacket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dhsjakd/utls/EventBus.dart';
import 'BLEPeripheral.dart';
import 'dart:async';

import "../flutter_native_channel/flutter_native_message.dart";
import '../flutter_native_channel/flutter_native_method.dart';

typedef BleCallback = void Function(dynamic value);

class BLECentralManager extends ChangeNotifier {
  static BleCallback bleCallback;
  static setBleCallback(BleCallback callback) {
    bleCallback = callback;
  }

  //单例
  factory BLECentralManager() => _getInstance();
  static BLECentralManager get instance => _getInstance();
  static BLECentralManager _instance;
  BLECentralManager._internal() {
    // 初始化
    _subscribeiOSMessageChannel();
    
  }
  static BLECentralManager _getInstance() {
    if (_instance == null) {
      _instance = new BLECentralManager._internal();
    }
    return _instance;
  }

  NativeFLTMessageChannel readMessageChannel = NativeFLTMessageChannel();

  //是否是自动连接
  bool isAutoConnect;
  //当前连接的外设
  BLEPeripheral connectedPeripheral;
  
  PAWDevice device;

  //读的特征
  var readCharacteristic;
  //写的特征
  var writeCharacteristic;

  //订阅ios主动消息；
  void _subscribeiOSMessageChannel() {
    readMessageChannel.registerCustomMessageFromNative(
        "startScanning/BlePeripheral", callback: (Map blePeripheral) {
      BLEPeripheral peripheral = BLEPeripheral(
          name: blePeripheral["name"], nickname: blePeripheral["nickname"]);
      eventBus.fire(BleCentralManagerEvent(peripheral));
    });

    readMessageChannel.registerCustomMessageFromNative(
        "ble_Disconnect", callback: (Map bleState) {
        bool isDisconnect = bleState["isBleDisconnect"];
        if (isDisconnect) {
          if (this.connectedPeripheral != null ) {
            this.cleanPeripheral();
            BleHeartbeatPacket().stop();
          }
        }
    });
  }

  void cleanPeripheral () {
    this.connectedPeripheral = null;
    this.device = null;
  }

  // 是否已连接外设
  Future<bool> isConnectPeripheral() async {
    bool isConnectPeripheral = await FLTNativeMethodChannel().sendMethod_V2("isConnectPeripheral/bool");
    return isConnectPeripheral;
  }

  /**
   * 
   * 开始扫描外设。传入指定的Service UUID，只扫描提供这些service的外设 uuids 数组中的类型为CBUUID
   */
  Future startScanning({bool isAutoConnect}) async {
    /*
  * invokeMethod<T>(String method, [dynamic arguments])
  * method：要调用的方法名
  * arguments：传参
  */
    Map arguments = Map();
    arguments["isAutoConnect"] = isAutoConnect;
    FLTNativeMethodChannel().sendMethod("startScanning", arguments: arguments,
        callback: (dynamic result) {
      return null;
    });
  }

  /**
   * 停止扫描外设
   */
  void stopScanning() {
    FLTNativeMethodChannel().sendMethod("stopScanning");
  }

  /** 连接外设 */

  Future connectPeripheral(
      BLEPeripheral peripheral, BleCallback complete) async {
    Map arguments = Map();
    arguments["peripheral_Name"] = peripheral.name;
    FLTNativeMethodChannel().sendMethod("connectPeripheralWithName",
        arguments: arguments, callback: (dynamic result) async {
      /*
        Map{
          "isConnect":bool,
          "peripheral":
            {
              "nickname":String,
              "name":String,
            }
          }
        */
      bool isConnect = false;
      Map dict = result;
      if (dict["isConnect"] as bool) {
        BLEPeripheral connectedPeripheral = BLEPeripheral(
            nickname: dict["peripheral"]["name"],
            name: dict["peripheral"]["name"]);
        this.connectedPeripheral = connectedPeripheral;
        stopScanning();
        isConnect = dict["isConnect"];
      } else {
        stopScanning();
      }
      if (complete != null) {
        complete(isConnect);
      }
    });
  }

  /** 断开连接外设 */
  void disconnectPeripheral() {
    FLTNativeMethodChannel().sendMethod("disconnectPeripheral");
  }

  /** 开始notify */

  void startNotify() {
    FLTNativeMethodChannel().sendMethod("startNotify");
  }

  /** 停止notify */

  void stopNotify() {
    FLTNativeMethodChannel().sendMethod("stopNotify");
  }

  /** 进入后台之后开始升级固件 */

  void intoTheBackgroundFirmwareContinue() {}
  /** 进入前台之后停止升级固件 */

  void intoTheForegroundStopFirmwareContinue() {}
}
