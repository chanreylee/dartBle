import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/DB/PAWMediaDetailedInfo.dart';
import 'package:dhsjakd/DB/PAWMediaDispatchCenter.dart';
import 'package:dhsjakd/DB/PAWMediaInfo.dart';
import 'package:dhsjakd/DB/paw_db/paw_db.dart';
import 'package:dhsjakd/DB/paw_db/sql_table_data.dart';
import 'package:dhsjakd/DB/paw_db/sql_util.dart';
import 'package:dhsjakd/ble__manager/BLEHeartbeatPacket.dart';
import 'package:dhsjakd/utls/EventBus.dart';
import 'package:flutter/foundation.dart';
import 'package:dhsjakd/DB/PAWDevice.dart';
import 'package:dhsjakd/DB/PAWDirectory.dart';
import 'package:dhsjakd/DB/PAWLibrary.dart';

import 'package:dhsjakd/ble__manager/BLECentralManager.dart';
import 'package:dhsjakd/ble__manager/BLEInterface.dart';
import 'package:dhsjakd/ble__manager/BLEStruct.dart';
import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEAuthorizeManager.dart';
import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEIOManager.dart';
import 'package:dhsjakd/ble__manager/ble_reformer/BleCheckCMDReformer.dart';
import 'package:dhsjakd/ble__manager/ble_reformer/setup_reformer/P3KSetupReformer.dart';
import 'package:dhsjakd/flutter_native_channel/native_methods.dart';
import 'package:dhsjakd/utls/NumsType.dart';

import 'PrivateMethods/BleConnectIOPMethods.dart';

class BleConnectIO implements ManagerDataInterface {

  
  ValueGetter loadedEndBlock;

  BleIOManager deviceStateManager;
  BLEAuthorizeManager authorizeManager;
  BleIOManager checkSetupkManager;
  BleIOManager readSetupManager;

  

  BleIOManager checkTotalList;
  BleIOManager readTotalList;

  BleIOManager checkMediaLists;
  BleIOManager readMediaLists;

  BleIOManager checkDirectoryName;
  BleIOManager readDirectoryName;

  BleIOManager checkMediaName;
  BleIOManager readMediaName;

  BleIOManager writeDirectoryNameList;
  BleIOManager checkDirectoryNameList;
  BleIOManager readDirectoryNameList;

  BleIOManager checkUpdateList;
  BleIOManager readUpdateList;
  BleIOManager writeUpdateList;

  int          oldKey;
  BleIOManager readPawKey;
  BleIOManager realTimeControlWriteKey;
  BleIOManager writeMineLike;

  int directoryCount; //读取列表目录 计数器

  PawLibrary pawLibrary;

  List<Map> mediaArr;
  int totalMediaCount;
  int currentMediaCount;
  int haveReadCount;

  List tempMediaNameArr = List();
  int  tempNewMeidaCount;
  List tempNewUploadMeidaArr = List();  //准备上传的 



  void getDeviceState() {
    this.deviceStateManager = BleIOManager(this)
      ..setupBtype(PAW_CMD_STATES)
      ..execute();
  }

   void getReadKey() {
     this.readPawKey = BleIOManager.readCMD(this)
        ..setupObjectId(DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY)
        ..setupLength(4)
        ..execute();
  }

  

  @override
  failCallback(Error err, BleIOManager manager) {
    // TODO: implement failCallback
    print(err);

    if (manager == this.authorizeManager) {
        BleHeartbeatPacket().stop();

    } else if (manager == this.realTimeControlWriteKey) {
        print("写Key 有问题");
        // [SVProgressHUD dismiss];
        //可以让用户进行操作
        BleHeartbeatPacket().start();
    }
  }

  @override
  successCallback(Uint8List data, BleIOManager manager) async {
    // TODO: implement successCallback
    if (manager == this.deviceStateManager) {

        this.authorizeManager = BLEAuthorizeManager(this)..execute();

    } else if (manager == this.authorizeManager) {

        if (manager.deviceState.arcIsAuthorized) {
          print("授权成功");
          
          SqlUtil deviceSqlUtil = SqlUtil.setTable(SqlTable.table_device);
          deviceSqlUtil.query(conditions: {"deviceId":BLECentralManager().connectedPeripheral.deviceId}).then((value) {
            if (value.length > 0) {
              //连接过
              PAWDevice pawDevice = PAWDevice.fromMap(value.first);
              BLECentralManager().device = pawDevice;
              this.getReadKey();

            } else {
              //第一次连接 获取设备设置详情
              this.checkSetupkManager = BleIOManager(this)
                ..setupBtype(PAW_CMD_CHECK)
                ..setupObjectId(DEVICE_OBJECTID_SETUP)
                ..execute();
            }
          });
        } else {
          print("授权失败");
        }

    } else if (manager == this.checkSetupkManager) {

        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
        this.readSetupManager = BleIOManager(this)
          ..setupLength(number)
          ..setupBtype(PAW_CMD_READ)
          ..setupObjectId(DEVICE_OBJECTID_SETUP)
          ..execute();
          
    } else if (manager == this.readSetupManager) {

        P3KSetupReformer setupReformer = P3KSetupReformer();
        Map p3KSetup = manager.fetchDataWithReformer(setupReformer);
        print(p3KSetup);
        BleConnectIOPMethods.saveDeveie(setupReformer, manager.deviceState);
        //禁止用户操作。
        NativeMethods.interactionEvents(true);

        this.checkTotalList = BleIOManager(this)
          ..setupBtype(PAW_CMD_CHECK)
          ..setupObjectId(DEVICE_OBJECTID_TOTAL_FOLDER_LIST)
          ..execute();

    } else if (manager == this.readPawKey) {

        //禁止用户进行操作
        //禁止用户操作。
        NativeMethods.interactionEvents(true);
        int key = manager.rawData.buffer.asByteData().getUint32(0);
        this.oldKey = key;
        if (BLECentralManager().device.key != this.oldKey || BLECentralManager().device.key == 0) {
            
          print("正在同步更新...");
          //开始读所有目录dbid dbpos
          this.checkTotalList = BleIOManager(this)
            ..setupBtype(PAW_CMD_CHECK)
            ..setupObjectId(DEVICE_OBJECTID_TOTAL_FOLDER_LIST)
            ..execute();
            
        } else {
          //设备 存储内容没有变更过 不用同步 直接读取手机本地库
          
          ByteData byteData = ByteData(4);
          byteData.setInt32(0, this.oldKey + 1);
          this.realTimeControlWriteKey = BleIOManager.writeCMD(this)
            ..setupObjectId(DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY)
            ..setupLength(4)
            ..setupSendData(byteData.buffer.asUint8List())
            ..execute();
        }
        
    } else if (manager == this.checkTotalList) {

        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
        this.readTotalList = BleIOManager.readCMD(this)
          ..setupLength(number)
          ..setupObjectId(DEVICE_OBJECTID_TOTAL_FOLDER_LIST)
          ..execute();

    } else if (manager == this.readTotalList) { // PAW_PLaylist_Header 结构

        ReadBuffer tempButter = ReadBuffer(manager.rawData.buffer.asByteData());
        tempButter.getUint32();tempButter.getUint32();
        
        this.pawLibrary = PawLibrary()
          ..pawId = BLECentralManager.instance.connectedPeripheral.deviceId
          ..listCount = tempButter.getUint32();

        // 清空原有数据。
        // PawDB.db.execute("TRUNCATE TABLE ${SqlTable.table_library}");
        PawDB.db.delete(SqlTable.table_library, where: "pawId = ?", whereArgs: [this.pawLibrary.pawId]);
        PawDB.db.insert(SqlTable.table_library, pawLibrary.toMap());
        PawDB.db.delete(SqlTable.table_directory, where: "ownerId = ?", whereArgs: [this.pawLibrary.pawId]);
        PawDB.db.delete(SqlTable.table_mediaInfo, where: "pawId = ?", whereArgs: [this.pawLibrary.pawId]);
        PawDB.db.delete(SqlTable.table_mediaDetailedInfo, where: "pawId = ?", whereArgs: [this.pawLibrary.pawId]);
        

        var batch = PawDB.db.batch();

        List<PawDirectory> pawDirectorys = List();
        Uint8List tempList = Uint8List(pawLibrary.listCount * 8);
        List.copyRange(tempList, 0, data, 12, 12 + pawLibrary.listCount * 8);
        ByteData byteData = tempList.buffer.asByteData();
        ReadBuffer readDirectoryBuffer = ReadBuffer(byteData);
        for (var i = 0; i < pawLibrary.listCount; i++) {
          PawDirectory pawDirectory = PawDirectory()
            ..dicDbId = readDirectoryBuffer.getUint32()
            ..dicDbPos = readDirectoryBuffer.getUint16()
            ..dicDbPad = readDirectoryBuffer.getUint16()
            ..ownerId = this.pawLibrary.pawId;
            
          batch.insert(SqlTable.table_directory, pawDirectory.toMap());
          pawDirectorys.add(pawDirectory);
        }
        this.pawLibrary.directorys = pawDirectorys;
        batch.commit();

        this.directoryCount = 0;
        if (this.directoryCount < this.pawLibrary.directorys.length) {
            PawDirectory pawDirectory = this.pawLibrary.directorys[this.directoryCount];
            this.checkDirectoryName = BleIOManager(this)
            ..setupBtype(PAW_CMD_CHECK)
            ..setupObjectId(DEVICE_OBJECTID_MEIDA_INFO)
            ..setupOffset(MEIDA_INFO_OFFSET_NAME)
            ..setupDbParam(pawDirectory.dicDbId, pawDirectory.dicDbPos)
            ..execute();
        }

    } else if (manager == this.checkDirectoryName) {
        
        PawDirectory pawDirectory = this.pawLibrary.directorys[this.directoryCount];
        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
        this.readDirectoryName = BleIOManager.readCMD(this)
        ..setupLength(number)
        ..setupObjectId(DEVICE_OBJECTID_MEIDA_INFO)
        ..setupOffset(MEIDA_INFO_OFFSET_NAME)
        ..setupDbParam(pawDirectory.dicDbId, pawDirectory.dicDbPos)
        ..execute();
        
    } else if (manager == this.readDirectoryName) {
      
        String dicName = String.fromCharCodes(manager.rawData.buffer.asUint16List());
        print(dicName);
        this.pawLibrary.directorys[this.directoryCount].dicName = dicName;
        SqlUtil directoryUtil = SqlUtil.setTable(SqlTable.table_directory);
        directoryUtil.update({"dicName":dicName}, "dicDbId", this.pawLibrary.directorys[this.directoryCount].dicDbId);
        
        this.directoryCount ++;
        if (this.directoryCount < this.pawLibrary.directorys.length) {
            PawDirectory pawDirectory = this.pawLibrary.directorys[this.directoryCount];
            int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
            this.readDirectoryName = BleIOManager.readCMD(this)
            ..setupLength(number)
            ..setupObjectId(DEVICE_OBJECTID_MEIDA_INFO)
            ..setupOffset(MEIDA_INFO_OFFSET_NAME)
            ..setupDbParam(pawDirectory.dicDbId, pawDirectory.dicDbPos)
            ..execute();
            
            // [SVProgressHUD showProgress:((this.directoryCount) / 1.0) / this.pawLibrary.directorys.count status:[NSString stringWithFormat:@"%@:%ld/%lu",IFMLocalizedString(@"加载歌曲列表", nil),(long)this.directoryCount,(unsigned long)this.pawLibrary.directorys.count]];
        } else {
            this.directoryCount = 0;
            if (this.directoryCount < this.pawLibrary.directorys.length) {
                // NSLog(@"开始读取所有歌曲id 和 pos");
                PawDirectory directory = this.pawLibrary.directorys[this.directoryCount];
                this.checkMediaLists = BleIOManager(this)
                  ..setupBtype(PAW_CMD_CHECK)
                  ..setupObjectId(DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER)
                  ..setupDbParam(directory.dicDbId, directory.dicDbPos)
                  ..execute();
                // [SVProgressHUD showWithStatus:IFMLocalizedString(@"开始加载歌曲信息...", nil)];
            }
        }

    } else if (manager == this.checkMediaLists) {
        
        PawDirectory directory = this.pawLibrary.directorys[this.directoryCount];
        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
        this.readMediaLists = BleIOManager.readCMD(this)
          ..setupLength(number)
          ..setupObjectId(DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER)
          ..setupDbParam(directory.dicDbId, directory.dicDbPos)
          ..execute();

    } else if (manager == this.readMediaLists) {
        
        List<PawMediaInfo> mediaInfos = BleConnectIOPMethods.saveMediaInfo(manager.rawData);  
        this.pawLibrary.directorys[this.directoryCount].medias = mediaInfos;
        
        this.directoryCount ++ ;
        if (this.directoryCount < this.pawLibrary.directorys.length) {
            
          PawDirectory directory = this.pawLibrary.directorys[this.directoryCount];
          this.checkMediaLists = BleIOManager(this)
            ..setupBtype(PAW_CMD_CHECK)
            ..setupObjectId(DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER)
            ..setupDbParam(directory.dicDbId, directory.dicDbPos)
            ..execute();
        } else {
            
            this.totalMediaCount = 0;
            this.currentMediaCount = 0;

            List mediasDatabase = List();

            for (int i = 0; i < this.pawLibrary.directorys.length; i++) {
                
                PawDirectory tempDirectory = this.pawLibrary.directorys[i];
                
                List tempArr = List();
                
                for (int j = 0; j < tempDirectory.medias.length; j++) {
                    
                    PawMediaInfo tempMediaInfo = tempDirectory.medias[j];

                    List data = await PawDB.db.query(
                      SqlTable.table_mediaDetailedInfo, 
                      where: "pawId = ? and songDbId = ?",
                      whereArgs: [BLECentralManager().connectedPeripheral.deviceId,tempMediaInfo.songDbId]
                    );

                    //以下if 操作可以 滤掉已经 paw 已经删除的歌曲。只留下未更改或者更新后的数据。

                    if (data.length == 0) {
                        Map dic = Map();
                        dic["mediaIndex"] = j;
                        dic["mediaId"] = tempMediaInfo.songDbId;
                        dic["mediaPos"] = tempMediaInfo.songDbPos;
                        dic["mediaPad"] = tempMediaInfo.songDbPad;
                        tempArr.add(dic); 
                        //新增的文件 给予dbid dbpos pad 放入数组 稍后统一请求详细文件信息 再放入当前PICO媒体库;

                        PawMediaDetailedInfo media = PawMediaDetailedInfo()
                          ..songDbId = tempMediaInfo.songDbId
                          ..songDbPos = tempMediaInfo.songDbPos
                          ..songDbPad = tempMediaInfo.songDbPad
                          ..pawId = BLECentralManager().connectedPeripheral.deviceId
                          ..fileName = "未命名"
                          ..suffix = "未识别";
                        mediasDatabase.add(media.toMap());

                    } else {
                        //未改变的文件 放回当前PICO媒体库
                        mediasDatabase.add(data.first);
                    }
                }

                Map dictionary = Map();
                dictionary["listId"] = tempDirectory.dicDbId;
                dictionary["listPos"] = tempDirectory.dicDbPos;
                dictionary["listIndex"] = tempArr;
                dictionary["listTotalCount"] = tempDirectory.medias.length;
                this.tempMediaNameArr.add(dictionary);
                if (tempArr.length > 0) {
                    this.totalMediaCount += tempArr.length;
                }
          }

          // 保存新数据
          PawDB.db.transaction((txn)async{
              mediasDatabase.forEach((media)async{
                await txn.insert("mediaDetailedInfo", media);
              });
            }
          );
          
          print("所有列表歌曲dbID和dbpos 读完");
          this.tempNewMeidaCount = 0;
          // 越过没有需要读的列表
          for (var i = tempNewMeidaCount; i <  this.tempMediaNameArr.length; i++) {
            Map currentDictionary = this.tempMediaNameArr[this.tempNewMeidaCount];
            List indexArr = (currentDictionary["listIndex"]);
            if (indexArr.length == 0) {
              this.tempNewMeidaCount ++;
            } else {
              break;
            }
          }
          if (this.tempNewMeidaCount < this.tempMediaNameArr.length) {
              //开始按顺序组织 每一份列表 需要请求歌曲的名字（或详情）；排 每组32位 列表；
              Map currentDictionary = this.tempMediaNameArr[this.tempNewMeidaCount];
              List indexArr = (currentDictionary["listIndex"]);
              
              //一次最大传输 200位 
              if (indexArr.length > 200) {
                  this.haveReadCount = 200;
              } else {
                  this.haveReadCount = indexArr.length;
              }

              Uint8List sendData = BleConnectIOPMethods.getPLaylistNameMapData(this.haveReadCount, 0, currentDictionary);

              print("写 ${this.haveReadCount} 个");
              this.writeDirectoryNameList = BleIOManager.writeCMD(this)
                ..setupSendData(sendData)
                ..setupObjectId(DEVICE_OBJECTID_PLAYLIST_NAMELIST)
                ..execute();

          } else {
            ByteData byteData = ByteData(4);
            byteData.setInt32(0, 1);

            this.realTimeControlWriteKey = BleIOManager.writeCMD(this)
            ..setupObjectId(DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY)
            ..setupLength(4)
            ..setupSendData(byteData.buffer.asUint8List())
            ..execute();

            print("没有歌曲了");

            //                //这里应该请求 修改列表
              //                [this.checkUpdateList setupObjectId:DEVICE_OBJECTID_MODIFY_MEIDA_LIST];
              //                [this.checkUpdateList execute];
          }
        }
    }  else if (manager == this.writeDirectoryNameList) {
        
        int dbid = this.tempMediaNameArr[this.tempNewMeidaCount]["listId"];
        int dbpos = this.tempMediaNameArr[this.tempNewMeidaCount]["listPos"];
        this.checkDirectoryNameList = BleIOManager(this)
          ..setupBtype(PAW_CMD_CHECK)
          ..setupObjectId(DEVICE_OBJECTID_PLAYLIST_NAMELIST)
          ..setupDbParam(dbid, dbpos)
          ..execute();
        
    } else if (manager == this.checkDirectoryNameList) {
        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());
        
        
        int dbid = this.tempMediaNameArr[this.tempNewMeidaCount]["listId"];
        int dbpos = this.tempMediaNameArr[this.tempNewMeidaCount]["listPos"];

        print("check number $number，listId:$dbid , 写 ${this.haveReadCount}个");
        this.readDirectoryNameList = BleIOManager.readCMD(this)
          ..setupObjectId(DEVICE_OBJECTID_PLAYLIST_NAMELIST)
          ..setupLength(number)
          ..setupDbParam(dbid, dbpos)
          ..execute();
    } else if (manager == this.readDirectoryNameList) {
        
        SqlUtil mediaDetailedInfoSql = SqlUtil.setTable("mediaDetailedInfo");
        var batch = mediaDetailedInfoSql.db.batch();

        Uint8List pNameItem = manager.rawData;
        print("实际 number ${manager.rawData.length}");
        ReadBuffer readBuffer = ReadBuffer(pNameItem.buffer.asByteData());
        readBuffer.getUint8List(8);
        // var pointer = 0;
        
        // PAW_PLaylist_NameItem 
        int remainingCount = 0;
        
        if (this.haveReadCount == 0) {
            remainingCount = 0;
        } else if (this.haveReadCount % 200 == 0) {
            remainingCount = this.haveReadCount - 200;
        } else if (this.haveReadCount % 200 != 0) {
            remainingCount = this.haveReadCount - this.haveReadCount % 200;
        }
        List mediaArr = this.tempMediaNameArr[this.tempNewMeidaCount]["listIndex"];
        // pointer += 8;
        for (int i = 8; i < pNameItem.length;) {
            
            if (pNameItem.length - i <= 8) {
              break;
            }
            bool isYes = false;
            int dbid = readBuffer.getUint32();
            int name_len = readBuffer.getUint32();
            this.pawLibrary.directorys[this.tempNewMeidaCount].mediaDetailedInfos = List();
            
            for (int j = 0; j < this.haveReadCount - remainingCount; j ++) {
                Map mediaDic = mediaArr[j + remainingCount];
                
                if (dbid == mediaDic["mediaId"]) {

                    isYes = true;
                    Uint8List nameList = Uint8List(name_len);
                    nameList.setRange(0, name_len, readBuffer.getUint8List(name_len));
                    String tempName = String.fromCharCodes(nameList.buffer.asUint16List());
                    print(tempName);
                    int range = tempName.indexOf(".");
                    String songName = "";
                    String suffix = "";
                    
                    if (range != -1) {
                        songName = tempName.substring(0,range);
                        suffix = tempName.substring(range + 1);
                    } else {
                        songName = tempName;
                        suffix = "未识别";
                    }

                    PawMediaDetailedInfo media = PawMediaDetailedInfo()
                      ..songDbId = mediaDic["mediaId"]
                      ..songDbPos = mediaDic["mediaPos"]
                      ..songDbPad = mediaDic["mediaPad"]
                      ..pawId = BLECentralManager().connectedPeripheral.deviceId
                      ..fileName = songName
                      ..suffix = suffix
                      ..qualityFromSuffix();
                    this.pawLibrary.directorys[this.tempNewMeidaCount].mediaDetailedInfos.add(media);
                    batch.update("mediaDetailedInfo", media.toMap() ,where: "songDbId = ${media.songDbId} and pawId = ${media.pawId}");
                    
                    this.tempNewUploadMeidaArr.add(media);
                    this.currentMediaCount ++;
                    // [SVProgressHUD showProgress:(this.currentMediaCount / 1.0) / this.totalMediaCount status:[NSString stringWithFormat:@"%@:%ld/%lu",IFMLocalizedString(@"新增歌曲", nil),(long)this.currentMediaCount,(unsigned long)this.totalMediaCount]];
                    
                    break;
                }
            }
            
            if (isYes) {
                int len = 0;
                if ((8 + name_len) % 4 == 0) {
                    len += 8 + name_len;
                } else {
                    int num = 4 - (8 + name_len) % 4;
                    len += num + 8 + name_len;
                    readBuffer.getUint8List(4 - name_len % 4);
                }
                i += len;
            } else {
              // print("文件有误/或者结束");
              break;
            }
        }
        batch.commit();

        if (mediaArr.length == this.haveReadCount) {
            this.tempNewMeidaCount ++;
            this.haveReadCount = 0;

              //如果下一个列表需要读取的数量是0 的话 则跳过
          for (var i = tempNewMeidaCount; i <  this.tempMediaNameArr.length; i++) {
              Map currentDictionary = this.tempMediaNameArr[this.tempNewMeidaCount];
              List indexArr = (currentDictionary["listIndex"]);
              if (indexArr.length == 0) {
                this.tempNewMeidaCount ++;
              } else {
                break;
              }
            }
            // print("新列表");
        }
        
        

        if (this.tempNewMeidaCount < this.tempMediaNameArr.length) {
            Map currentDictionary = this.tempMediaNameArr[this.tempNewMeidaCount];
            List indexArr = (currentDictionary["listIndex"]);
            int countIndex = 0;
            
            if (this.haveReadCount == 0) {
                if (indexArr.length > 200) {
                    this.haveReadCount = 200;
                } else {
                    this.haveReadCount = indexArr.length;
                }
            } else if (this.haveReadCount % 200 == 0) {
                countIndex = this.haveReadCount;
                if (indexArr.length - this.haveReadCount > 200) {
                    this.haveReadCount += 200;
                } else {
                    this.haveReadCount = indexArr.length;
                }
            }

            Uint8List sendData = BleConnectIOPMethods.getPLaylistNameMapData(this.haveReadCount, countIndex, currentDictionary);
            this.writeDirectoryNameList = BleIOManager.writeCMD(this)
              ..setupSendData(sendData)
              ..setupObjectId(DEVICE_OBJECTID_PLAYLIST_NAMELIST)
              ..execute();
            
        } else {
        
        //所有名字读完
        // [SVProgressHUD showWithStatus:IFMLocalizedString(@"开始更新歌曲信息...", nil)];
        
        // 新增文件更新完事 开始获取被修改信息的歌曲
        
        ByteData byteData = ByteData(4);
        byteData.setInt32(0, this.oldKey + 1);
        this.realTimeControlWriteKey = BleIOManager.writeCMD(this)
          ..setupObjectId(DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY)
          ..setupLength(4)
          ..setupSendData(byteData.buffer.asUint8List())
          ..execute();
        
// #pragma - 这里开始有请求更新过的媒体信息列表
        //
        //            [this.checkUpdateList setupObjectId:DEVICE_OBJECTID_MODIFY_MEIDA_LIST];
        //            [this.checkUpdateList execute];
        
      }
        
    } else if (this.realTimeControlWriteKey == manager) {
        
        BLECentralManager().device.key = 1;

        Uint32List mineLike = Uint32List(400);
        mineLike[1] = 0xF0000;
        mineLike[2] = 0;
        
        for (var i = 0; i < 1; i++) {
          mineLike[3 + i * 2] = 0;
          Uint16List temp = Uint16List(2);
          temp[0] = 0;
          temp[1] = 1;
          mineLike[4 + i * 2] = temp.buffer.asByteData().getUint32(0);
        }

        ByteData sendData = ByteData.view(mineLike.buffer, 0, 8 + 8); //length:sizeof(P3k_PLaylist_Header)+sizeof(P3k_PLaylist_Item)
        
        this.writeMineLike = BleIOManager.writeCMD(this)
          ..setupObjectId(DEVICE_OBJECTID_PLAYLIST)
          ..setupSendData(sendData.buffer.asUint8List())
          ..execute();
    } else if (manager == this.writeMineLike) {
        
        print("文件信息加载成功");

        PAWMediaDispatchCenter();
        
        //可以让用户进行操作
        NativeMethods.interactionEvents(true);
      
        // this._loadEnd();
        if (this.loadedEndBlock != null) {
            this.loadedEndBlock();
        }
    } 
  }

  void _loadEnd () {

    if (this.loadedEndBlock != null) {
      // BleHeartbeatPacket().isCanStart = true;
      //   if (BleHeartbeatPacket().isCanStart) {
      //       BleHeartbeatPacket().start();
      //   }
      this.loadedEndBlock();
    }
  }
}
