import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';


import '../BLEInterface.dart';
import '../BLEStruct.dart';
import 'BLEIOManager.dart';

// 可获取状态后直接 进行绑定，内部实现 授权->绑定 两次命令。
class BLEBindManager extends BleIOManager {
  BLEBindManager(ManagerDataInterface managerDataInterface ,{Uint8List data}) : super(managerDataInterface);
  Uint8List data = Uint8List(0x10);
  @override
  void execute() {
    // TODO: implement execute
   
    this..setupObjectId(DEVICE_OBJECTID_AUTHORIZE)
        ..setupBtype(PAW_CMD_WRITE)
        ..setupOffset(AUTHORIZE_OFFSET_BIND)
        ..setupLength(PAW_KEY_LENGTH)
        ..setupSendData(data);
    super.execute();
  }
}