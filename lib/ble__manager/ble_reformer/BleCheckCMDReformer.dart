import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEIOManager.dart';

class BleCheckCMDReformer extends BLEManagerCallbackReformer {
  @override
  int bleManagerReformer(BleIOManager manager, Uint8List reformData) {
    int len = reformData.buffer.asByteData().getUint32(8, Endian.little);

    return len;
  }
}
