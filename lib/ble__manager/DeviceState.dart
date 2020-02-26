
import 'dart:typed_data';

import 'BLEStruct.dart';

class DeviceState {
  Uint8List stateData;

  bool isTransmiting; // 数据传输过程中
  bool isCharging; // 设备正在充电
  bool isWritting; // 正在将数据写入硬件
  bool isBind; // 设备是否已绑定
  bool isAuthorized; // 设备是否已验证
  bool isRealTimeControl; // 设备是否正在处理控制
  bool isUsbConnection; //USB 是否连接中
  int battery; // 设备电量千分比
  int operationPercent; // 当前命令进行的百分比
  int hardwareVersion; // 硬件版本号
  int firmwareVersion; // 固件版本号
  int gpsVersion; // gps版本号
  int bleVersion; // ble版本号
  int lastCMDType; // 上一次的cmd type
  int objectID; // 读或写的objectID
  int lastCMDResult; // 上一次的cmd result for debug
  String lastCMDResultString; // 上一次的cmd result
/*
 填充设备状态数据
 */
  DeviceState.fillDeviceStateWithMap(Map map) {
    this.isTransmiting = map["isTransmiting"]
      ..isCharging = map["isCharging"]
      ..isWritting = map["isWritting"]
      ..isBind = map["isBind"]
      ..isAuthorized = map["isAuthorized"]
      ..isRealTimeControl = map["isRealTimeControl"]
      ..isUsbConnection = map["isUsbConnection"]
      ..battery = map["battery"]
      ..operationPercent = map["operationPercent"]
      ..hardwareVersion = map["hardwareVersion"]
      ..firmwareVersion = map["firmwareVersion"]
      ..gpsVersion = map["gpsVersion"]
      ..bleVersion = map["bleVersion"]
      ..lastCMDType = map["lastCMDType"]
      ..objectID = map["objectID"]
      ..lastCMDResult = map["lastCMDResult"]
      ..lastCMDResultString = map["lastCMDResultString"];
  }

  DeviceState.fillDeviceStateWithData(Uint8List data) {
    this.stateData = data;
  }

  // Uint8 btype;				/* 帧头命令 */
  // Uint8 bno;				/* 上一个命令的处理结果 */
  // Uint8 otype;				/* last cmd */
  // Uint8 ono;				/* last pkt no */
  // Uint16 oobjID;			/* last object id(if exists) */
  // Uint16 devstate;			/* 当前的设备状态 */
  // Uint8 battery;			/* 电池电量 */
  // Uint8 oppercent;			/* 当前操作的完成百分比 */
  // Uint8 hwver;				/* 硬件版本号 */
  // Uint8 fwver;				/* 固件版本号 */
  // Uint8 gpsver;				/* GPS版本号 */
  // Uint8 blever;				/* ble固件版本号 */
  // Uint8List  pad = Uint8List(BLE_MAX_MTU_SIZE - 14);

  get arcLastCMDResult {


    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[1];
    }
    return ret;
  }

  get arcLastCMDType {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[2];
    }
    return ret;
  }

  get arcObjectID {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    
    if (btype == PAW_CMD_STATES) {

      final int value = this.stateData.buffer.asByteData().getUint16(4, Endian.little);
      ret = value;
    }
    return ret;
  }

  get arcIsTransmiting {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_TRANSMITING) > 0 ? true : false;
    }
    return ret;
  }

  get arcIsCharging {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_CHARGING) > 0 ? true : false;
    }
    return ret;
  }

  get arcIsWritting {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_WRITTING) > 0 ? true : false;
    }
    return ret;
  }

  get arcIsBind {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_BIND) > 0 ? true : false;
    }
    return ret;
  }

  get arcIsAuthorized {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_AUTHORIZED) > 0 ? true : false;
      
    }
    return ret;
  }

  get arcIsRealTimeControl {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_RT_PROCESS) > 0 ? true : false;
    }
    return ret;
  }

  get arcIsUsbConnection {
    int btype = this.stateData.toList()[0];
    bool ret = false;
    //
    if (btype == PAW_CMD_STATES) {
      final int value = this.stateData.buffer.asByteData().getUint16(6, Endian.little);
      ret = (value & DEVICE_STATE_USB_CONNETING) > 0 ? true : false;
    }
    return ret;
  }

  get arcBattery {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[6];
    }
    return ret;
  }

  get arcOperationPercent {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[7];
    }
    return ret;
  }

  get arcHardwareVersion {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[8];
    }
    return ret;
  }

  get arcFirmwareVersion {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[9];
    }
    return ret;
  }

  get arcGpsVersion {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[10];
    }
    return ret;
  }

  get arcBleVersion {
    int btype = this.stateData.toList()[0];
    int ret = 0;
    //
    if (btype == PAW_CMD_STATES) {
      ret = this.stateData.toList()[11];
    }
    return ret;
  }

  get arcLastCMDResultString {
    int lastCMDResult = this.arcLastCMDResult as int;
    String lastCMDType = this.arcLastCMDType.toString();
    String string = null;

    switch (lastCMDResult) {
      case RET_CODE_NORMAL:
        {
          string = "命令:" + lastCMDType + "操作成功";
        }
        break;
      case RET_CODE_DATA_OFFSET_ERR:
        {
          string = "命令:" + lastCMDType + "操作失败 读或写的frameoff有错误";
        }
        break;
      case RET_CODE_DATA_LEN_ERR:
        {
          string = "命令:" + lastCMDType + "操作失败 读或写的len有错误";
        }
        break;
      case RET_CODE_DATA_TRANS_OK:
        {
          string = "命令:" +
              lastCMDType +
              " 操作成功 cmdWrite时dev通过收到的数据长度判断已经传输完毕, cmdRead时dev发送完毕";
        }
        break;
      case RET_CODE_WDATA_ERR:
        {
          string = "命令:" + lastCMDType + " 操作失败 Dev检查出收到的数据有错误";
        }
        break;
      case RET_CODE_WDATA_PKTNO_ERR:
        {
          string = "命令:" + lastCMDType + " 操作失败 包编号错";
        }
        break;
      case RET_CODE_NO_AUTHORIZED:
        {
          string = "命令:" + lastCMDType + " 操作失败 未验证时，收到验证命令以外的其它命令";
        }
        break;
      case RET_CODE_IS_WRITING:
        {
          string = "命令:" + lastCMDType + " 操作失败 处在writing状态时收到新的COMW";
        }
        break;
      case RET_CODE_PARAM_ERR:
        {
          string = "命令: " + lastCMDType + " 操作失败 收到的参数有错误";
        }
        break;
      case RET_CODE_DISK_ERR:
        {
          string = "命令: " + lastCMDType + " 磁盘出现错误，生成alp文件失败";
        }
        break;
      default:
        break;
    }

    return string;
  }
}
