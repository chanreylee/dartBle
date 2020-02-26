//初始化Bus
import 'package:dhsjakd/DB/PAWDevice.dart';
import 'package:dhsjakd/DB/PAWDirectory.dart';
import 'package:dhsjakd/DB/PAWLibrary.dart';
import 'package:dhsjakd/DB/PAWMediaDetailedInfo.dart';
import 'package:dhsjakd/DB/PAWMediaInfo.dart';
import 'package:event_bus/event_bus.dart';
import 'package:dhsjakd/ble__manager/BLEPeripheral.dart';

EventBus eventBus = EventBus();

/// Event 修改主题色
class BleCentralManagerEvent {
  BLEPeripheral scannedPeripheral;
  BleCentralManagerEvent(this.scannedPeripheral);
  
}

class Name {
  
}

class PawHeartbeatEvent {

  bool isChange = false;

  PawHeartbeatEvent({this.isChange});

  // PAWDevice currentDevice;
  // PawLibrary currentLibrary;
  // PawDirectory currentDirectory;
  // PawMediaInfo currentMediaInfo;
  // PawMediaDetailedInfo currentDetailedInfo;
  // List<PawMediaInfo> currentListMeidaArr;
  // List<PawMediaDetailedInfo> currentRandomListMeidaArr;

  // PawDBEvent(
  //     {this.currentDevice,
  //     this.currentLibrary,
  //     this.currentDirectory,
  //     this.currentMediaInfo,
  //     this.currentDetailedInfo,
  //     this.currentListMeidaArr,
  //     this.currentRandomListMeidaArr});
}

class CurrentMediaInfoEvent {

  bool isChange = false;

  CurrentMediaInfoEvent({this.isChange});

  // String currentSongName;
  // int currentMediaIndex;
  // int currentRandomMediaIndex;
  // int currentDirectoryId;
  // int currentDirectoryPos;

  // CurrentMediaInfoEvent(
  //     {this.currentSongName,
  //     this.currentMediaIndex,
  //     this.currentRandomMediaIndex,
  //     this.currentDirectoryId,
  //     this.currentDirectoryPos});
}
