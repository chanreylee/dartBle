
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:dhsjakd/DB/PAWDevice.dart';
import 'package:dhsjakd/DB/PAWMediaInfo.dart';
import 'package:dhsjakd/DB/paw_db/paw_db.dart';
import 'package:dhsjakd/DB/paw_db/sql_table_data.dart';
import 'package:dhsjakd/DB/paw_db/sql_util.dart';
import 'package:dhsjakd/ble__manager/BLECentralManager.dart';
import 'package:dhsjakd/ble__manager/DeviceState.dart';
import 'package:dhsjakd/ble__manager/ble_reformer/setup_reformer/P3KSetupReformer.dart';
import 'package:dhsjakd/utls/DataConvertTool.dart';
import 'package:dhsjakd/utls/NumsType.dart';
import 'package:flutter/foundation.dart';

class BleConnectIOPMethods {

  static List<PawMediaInfo> saveMediaInfo (Uint8List rawData) {
    // PAW_PLaylist_Item item;
      ReadBuffer readBuffer = ReadBuffer(rawData.buffer.asByteData());
      readBuffer.getUint32();
      int list_dbid = readBuffer.getUint32();
      int item_num = readBuffer.getUint32();

      // print("列表${this.directoryCount+1} -- 歌曲数量$item_num");
      
      var batch = PawDB.db.batch();
      List<PawMediaInfo> mediaInfos = List();

      for (int i = 0; i < item_num; i++) {

          PawMediaInfo mediaInfo = PawMediaInfo()
            ..songDbId = readBuffer.getUint32()
            ..songDbPos = readBuffer.getUint16()
            ..songDbPad = readBuffer.getUint16()
            ..directory_ownerId = list_dbid
            ..pawId = BLECentralManager().connectedPeripheral.deviceId;
          batch.insert(SqlTable.table_mediaInfo, mediaInfo.toMap());
          mediaInfos.add(mediaInfo);
      }
      batch.commit();

      return mediaInfos;
  }

  static void saveDeveie (P3KSetupReformer setupReformer, DeviceState deviceState) {
      PAWDevice device = PAWDevice();
      device.deviceId = BLECentralManager.instance.connectedPeripheral.deviceId;
      device.deviceName = BLECentralManager.instance.connectedPeripheral.name;
      device.deviceNickName = BLECentralManager.instance.connectedPeripheral.nickname;
      // device.key = 0;
      device.fileCount = setupReformer.getFileCount().getValue;
      device.diskCapacity = setupReformer.getDiskCapacity();
      device.remainCapacity = setupReformer.getRemainCapacity();
      device.devModel = setupReformer.getDevModel();
      device.serialNo = setupReformer.getSerialNo();
      device.firewareVersion = deviceState.firmwareVersion.toString();
      device.bleVersion = setupReformer.getBleVersion();
      device.time = DateTime.now().millisecondsSinceEpoch;

      SqlUtil deviceUtil = SqlUtil.setTable(SqlTable.table_device);
      deviceUtil.insert(device.toMap());
      BLECentralManager().device = device;
  }

  static Uint8List getPLaylistNameMapData (int haveReadCount, int countIndex, Map dictionary) {
      int item_count = haveReadCount ~/ 32 + (haveReadCount % 32 > 0 ? 1 : 0);
      int itemTotalCount = dictionary["listTotalCount"];
      List indexArr = (dictionary["listIndex"]);
      // PAW_PLaylist_Name_Map
      Uint8List xu8 = Uint8List(1024);

      ByteData pLaylist_Name_Map = xu8.buffer.asByteData()
        ..setUint32(0, dictionary["listId"], Endian.little)
        ..setUint16(4, dictionary["listPos"], Endian.little)
        ..setUint16(6, itemTotalCount, Endian.little);

      Uint32List items = Uint32List(item_count);
      for (int i = countIndex; i < haveReadCount; i ++) {
          Map dic = indexArr[i];
          items[dic["mediaIndex"] ~/ 32] |= (0x1 << (dic["mediaIndex"] % 32));
      }
      
      for (var i = 0; i < items.length; i++) {
        pLaylist_Name_Map.setUint32(8 + i * 4, items[i], Endian.little);
      }

      // if(Platform.isIOS){
      //   int listId = reversedDataToiOS(dictionary["listId"], 4, true);
      //   int listPos = reversedDataToiOS(dictionary["listPos"], 2, true);
      //   int totalCount = reversedDataToiOS(itemTotalCount, 2, true);

      //   pLaylist_Name_Map.setUint32(0, listId);
      //   pLaylist_Name_Map.setUint32(4, listPos);
      //   pLaylist_Name_Map.setUint32(6, totalCount);

      //   Uint32List iOS_items = Uint32List(item_count);
      //   for (var i = 0; i < items.length; i++) {
      //     iOS_items[i] = reversedDataToiOS(items[i], 4, true);
      //     pLaylist_Name_Map.setUint32(8 + i * 4, iOS_items[i]);
      //   }
      // } else if(Platform.isAndroid);

      int len = 8 + 4 * (itemTotalCount ~/ 32 + 1);

      var copylist = new Uint8List(len);
      copylist.setRange(0, copylist.length, pLaylist_Name_Map.buffer.asUint8List());
      
      // ByteData data = ByteData.view(pLaylist_Name_Map.buffer, 0, len);
      // castBytes(data.buffer.asUint8List(), copy: true);;

      return copylist;
  }
}



  
