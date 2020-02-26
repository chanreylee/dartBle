import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEIOManager.dart';

import '../BLEStruct.dart';
import '../DeviceState.dart';

class BleDeviceStateReformer extends BLEManagerCallbackReformer {
  @override
  DeviceState bleManagerReformer(BleIOManager manager, Uint8List reformData) {
    int btype = reformData.toList()[0];

    if (btype == PAW_CMD_STATES) {
      DeviceState device = DeviceState.fillDeviceStateWithData(reformData);
      return device;
    }

    return null;
  }
}
