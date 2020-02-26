import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';


import '../BLEInterface.dart';
import '../BLEStruct.dart';
import 'BLEIOManager.dart';

// 可获取状态后直接 进行解绑，内部实现 授权->解绑 两次命令。
class BLEUnBindManager extends BleIOManager {
  BLEUnBindManager(ManagerDataInterface managerDataInterface ,{Uint8List data}) : super(managerDataInterface);
  Uint8List data = Uint8List(0x10);
  @override
  void execute() {
    // TODO: implement execute
    this..setupObjectId(DEVICE_OBJECTID_AUTHORIZE)
    ..setupBtype(PAW_CMD_WRITE)
    ..setupOffset(AUTHORIZE_OFFSET_UNBIND);
    super.execute();
  }
}