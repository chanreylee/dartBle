import 'dart:ffi';
import 'dart:typed_data';

// import 'package:buffer/buffer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dhsjakd/utls/NumsType.dart';

import 'DeviceState.dart';
import 'ble_IO_manager/BLEIOManager.dart';

abstract class ManagerDataInterface {
  //
  successCallback(Uint8List data, BleIOManager manager);
  failCallback(Error err, BleIOManager manager);
}

/*
  {
    data:<Uint8List>, 头20字节 是 deviceState
    success:bool,
    errorType:<Uint32>,
    errorReason:<String>,
  }
*/
class BLEResult {
  BLEResult({dynamic result}) {
    bool success = result["success"] as bool;
    if (success) {
      this.isSuccess = true;
      Uint8List tempData = castBytes(result["data"], copy: true);
      this.data = tempData;
      // this.deviceState = DeviceState.fillDeviceStateWithMap(responseObjectMap["deviceState"]);
      this.deviceState = DeviceState.fillDeviceStateWithData(tempData);
    } else {
      this.isSuccess = false;
      this.err = ArgumentError(result["errorReason"]);
    }
  }

  bool isSuccess;
  ArgumentError err; //safeToString

  Uint8List data;
  DeviceState deviceState;
}
