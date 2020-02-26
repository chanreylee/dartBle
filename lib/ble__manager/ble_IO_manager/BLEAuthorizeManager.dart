import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';


import '../BLEInterface.dart';
import '../BLEStruct.dart';
import 'BLEIOManager.dart';

class BLEAuthorizeManager extends BleIOManager {
  BLEAuthorizeManager(ManagerDataInterface managerDataInterface) : super(managerDataInterface);

  @override
  void execute() {
    // TODO: implement execute
    Uint8List data = Uint8List(PAW_KEY_LENGTH);
    this..setupObjectId(DEVICE_OBJECTID_AUTHORIZE)
    ..setupBtype(PAW_CMD_WRITE)
    ..setupOffset(AUTHORIZE_OFFSET_AUTH)
    ..setupLength(PAW_KEY_LENGTH)
    ..setupSendData(data);
    super.execute();
  }


}