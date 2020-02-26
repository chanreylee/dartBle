import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/DB/PAWDevice.dart';
import 'package:dhsjakd/DB/PAWPlayerManger.dart';
import 'package:dhsjakd/ble__manager/BLECentralManager.dart';

import 'BLEInterface.dart';
import 'BLEStruct.dart';
import 'ble_IO_manager/BLEIOManager.dart';

class BleHeartbeatPacket implements ManagerDataInterface {
  
  // @property (nonatomic, weak) id<IFMHeartbeatPacketDelegate>   delegate;
  
  Timer                  timer;
  BleIOManager           deviceStateManager;
  int                    num;
  PAWDevice              device;
  Duration               timeInterval;
  BleIOManager           readRTInfo;
  BleIOManager           checkRTInfo;
  bool                   isProcess;
  bool                   isUSB;

  bool                   isCanStart;

//单例
  factory BleHeartbeatPacket() => _getInstance();
  static BleHeartbeatPacket get instance => _getInstance();
  static BleHeartbeatPacket _instance;
  BleHeartbeatPacket._internal() {
    // 初始化
    // _subscribeiOSMessageChannel();
  }
  static BleHeartbeatPacket _getInstance() {
    if (_instance == null) {
      _instance = new BleHeartbeatPacket._internal();
    }
    return _instance;
  }

  

  bool isOnTimer () {
    return this.timer == null ? true : false;
  }

  void start () {
    this.timeInterval = Duration(milliseconds:360);
    this.startTimer();
  }

  void stop () {
    this.stopTimer();
    if (!BLECentralManager().isConnectPeripheral()) {
      print("检测到主控制中心没有连接外部设备,心跳包停止发送");
      this.isCanStart = false;
      BLECentralManager().startScanning(isAutoConnect: true);
    }
  }

  void startTimer () {
    if (this.timer == null) {
      this.timer = Timer(this.timeInterval, sendReadRTInfo);
    }
}

  void stopTimer () {
    if (this.timer != null) {
        this.timer?.cancel();
        this.timer = null;
    }
  }

  void setupIsStartSport (bool isStartSport) {
   
  }

  void sendReadRTInfo () {
    
    if (!this.isCanStart) {
        return;
    }
    //正在实时控制。。
    if (this.isProcess) {
      this.deviceStateManager = BleIOManager(this)
        ..setupBtype(PAW_CMD_STATES)
        ..execute();
    } else {
      this.readRTInfo = BleIOManager(this)
        ..setupObjectId(DEVICE_OBJECTID_CONTROL)
        ..setupBtype(CONTROL_OFFSET_RT_INFO_ALL)
      // sizeOf(Ble_RT_Info()) 36;
        ..setupLength(36)
        ..execute();
    }
  }

@override
  failCallback(Error err, BleIOManager manager) {
    // TODO: implement failCallback
    print(err);
  }

  @override
  successCallback(Uint8List data, BleIOManager manager) {
    // TODO: implement successCallback
    if (manager == this.deviceStateManager) {
        this.num = 0;
        // [SVProgressHUD dismiss];
        
        if (manager.deviceState.arcIsUsbConnection) {
            this.isUSB = true;
        } else {
            if (this.isUSB) {
              if (BLECentralManager().isConnectPeripheral()) {
                    BLECentralManager().disconnectPeripheral();
                    this.isUSB = false;
                    return;
                }
            }
        }
        if (manager.deviceState.arcIsRealTimeControl) {
            this.isProcess = true;
            this.startTimer();
        } else {
            this.isProcess = false;
            this.startTimer();
        }
    } else if (manager == this.readRTInfo) {
        // [SVProgressHUD dismiss];
        this.num = 0;
        PawPlayManger().fillRTInfoWithData(manager.rawData);
        
        if (manager.deviceState.arcIsUsbConnection) {
            this.isUSB = true;
        } else {
            if (this.isUSB) {
                
                if (BLECentralManager().isConnectPeripheral()) {
                    BLECentralManager().disconnectPeripheral();
                    this.isUSB = false;
                    return;
                }
            }
        }
        
        if (manager.deviceState.arcIsRealTimeControl) {

            this.isProcess = true;
            this.startTimer();
        } else {
            this.isProcess = false;
            this.startTimer();
        }
    }
  }



}