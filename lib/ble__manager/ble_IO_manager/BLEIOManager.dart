import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/flutter_native_channel/flutter_native_method.dart';
import 'package:dhsjakd/utls/NumsType.dart';

import '../BLEHeartbeatPacket.dart';
import '../BLEInterface.dart';
import '../BLEStruct.dart';
import '../DeviceState.dart';
// import 'package:buffer/buffer.dart';

// 解析器接口
abstract class BLEManagerCallbackReformer {
  //
  dynamic bleManagerReformer(BleIOManager manager, Uint8List reformData);
}

class BleIOManager {
  final ManagerDataInterface _managerDataInterface;

  //自定义命令
  BleIOManager(this._managerDataInterface);

  //写命令
  BleIOManager.writeCMD(this._managerDataInterface) {
    setupBtype(PAW_CMD_WRITE);
  }

  //读命令
  BleIOManager.readCMD(this._managerDataInterface) {
    setupBtype(PAW_CMD_READ);
  }

  //终止命令
  BleIOManager.breakCMD(this._managerDataInterface) {
    setupBtype(PAW_CMD_BREAK);
  }

  //获取设备状态
  BleIOManager.getDeviceState(this._managerDataInterface) {
    setupBtype(PAW_CMD_STATES);
  }

  //绑定设备(需要先进行设备授权,授权状态为ture,设备才能响应其他命令，包括绑定)
  BleIOManager.bind(this._managerDataInterface, {Uint8List data}) {
    setupObjectId(DEVICE_OBJECTID_AUTHORIZE);
    setupBtype(PAW_CMD_WRITE);
    setupOffset(AUTHORIZE_OFFSET_BIND);
    setupLength(PAW_KEY_LENGTH);
    setupSendData(data);
  }

  //设备解绑（需要先进行设备授权）
  BleIOManager.unBind(this._managerDataInterface) {
    setupObjectId(DEVICE_OBJECTID_AUTHORIZE);
    setupBtype(PAW_CMD_WRITE);
    setupOffset(AUTHORIZE_OFFSET_UNBIND);
  }

  // Pointer pointer = Pointer.fromAddress(0);
  XUint8 _btype = XUint8(0);
  XUint16 _objectId = XUint16(0);
  XUint32 _offset = XUint32(0);
  XUint32 _length = XUint32(0);
  XUint16 _param;
  XUint32 _dbid;
  XUint16 _dbpos;
  Uint8List _sendData;

  Map _sendMap = {};

  Uint8List rawData;

  DeviceState deviceState;
//   @optional

  int getObjectId() {
    return this._objectId.getValue;
  }

  Map getRawMap() {
    return this._sendMap;
  }

  void setupObjectId(int objectId_u16) {
    this._objectId = XUint16(objectId_u16);
    this._sendMap["objectId"] = this._objectId.getValue;
  }

  void setupBtype(int btype_u8) {
    this._btype = XUint8(btype_u8);
    this._sendMap["btype"] = this._btype.getValue;
  }

  void setupSendData(Uint8List sendData) {
    this._sendData = sendData;
    this._sendMap["data"] = this._sendData;
  }

  void setupLength(int length_u32) {
    this._length = XUint32(length_u32);
    this._sendMap["length"] = this._length.getValue;
  }

  void setupOffset(int offset_u32) {
    this._offset = XUint32(offset_u32);
    this._sendMap["offset"] = this._offset.getValue;
  }

  void setupDbParam(int dbid_u32, int dbpos_16) {
    this._dbid = XUint32(dbid_u32);
    this._dbpos = XUint16(dbpos_16);
    this._sendMap["dbid"] = this._dbid.getValue;
    this._sendMap["dbpos"] = this._dbpos.getValue;
  }

  void setupParam(int param_u16) {
    this._param = XUint16(param_u16);
    this._sendMap["param"] = this._param.getValue;
  }

  void execute() {

    //准备进入非空闲状态,停止心跳包
    if (BleHeartbeatPacket().isOnTimer()) {
        BleHeartbeatPacket().stop();
    }
    FLTNativeMethodChannel().sendMethod("writeBleValue",
        arguments: this._sendMap, callback: (dynamic result) {
      BLEResult bleResult = BLEResult(result: result);
      this.deviceState = bleResult.deviceState;
      //进入空闲状态,开始发送心跳包
      if (BleHeartbeatPacket().isCanStart) {
        BleHeartbeatPacket().start();
      }
      if (bleResult.isSuccess) {

        int id = this.deviceState.arcObjectID;
        successCallback(bleResult.data);
      } else {
        failCallback(bleResult.err);
      }
      return null;
    });
  }

  void successCallback(Uint8List data) {
    
    this.rawData = data;
    this._managerDataInterface.successCallback(this.rawData, this);
    
  }

  void failCallback(Error err) {
    this._managerDataInterface.failCallback(err, this);
  }

  dynamic fetchDataWithReformer(BLEManagerCallbackReformer reformer) {
    dynamic resultData = null;
    try {
      resultData = reformer.bleManagerReformer(this, this.rawData);
    } catch (err) {
      resultData = this.rawData;
    }
    return resultData;
  }
}
