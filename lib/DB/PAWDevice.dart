

class PAWDevice {

  int     deviceId;         //设备Id 
  String  deviceName;       //设备广播的名字
  String  deviceNickName;   //昵称
  int     time;             //绑定时间// 或者链接更新时间 时间戳
  String  ephemerisName;    //星历
  int     key;              //pawone 是否更新过 key 不一样则不一样。


  int     fileCount;        //歌曲数量
  String  diskCapacity;     //磁盘总容量
  String  remainCapacity;   //磁盘可用容量
  String  devModel;         //型号
  String  serialNo;         //序列号
  String  firewareVersion;  //固件版本
  String  bleVersion;       //蓝牙芯片版本@end

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['deviceId'] = deviceId;
    map['deviceName'] = deviceName;
    map['deviceNickName'] = deviceNickName;
    map['time'] = time;
    map['ephemerisName'] = ephemerisName;
    map['key'] = key;
    map['fileCount'] = fileCount;
    map['diskCapacity'] = diskCapacity;
    map['remainCapacity'] = remainCapacity;
    map['devModel'] = devModel;
    map['serialNo'] = serialNo;
    map['firewareVersion'] = firewareVersion;
    map['bleVersion'] = bleVersion;
    return map;
  }

  static PAWDevice fromMap(Map<String, dynamic> map) {
    PAWDevice device = PAWDevice();
    device.deviceId = map['deviceId'];
    device.deviceName = map['deviceName'];
    device.deviceNickName = map['deviceNickName'];
    device.time = map['time'];
    device.ephemerisName = map['ephemerisName'];
    device.key = map['key'];
    device.fileCount = map['fileCount'];
    device.diskCapacity = map['diskCapacity'];
    device.remainCapacity = map['remainCapacity'];
    device.devModel = map['devModel'];
    device.serialNo = map['serialNo'];
    device.firewareVersion = map['firewareVersion'];
    device.bleVersion = map['bleVersion'];
    return device;
  }



}