import 'DeviceState.dart';

class BLEPeripheral {
  String name;
  String nickname;
  DeviceState deviceState;

  BLEPeripheral({this.nickname,this.name});

  int get deviceId  {
    return int.parse(this.name.substring(6));
  }
}