import 'dart:ffi';
import 'dart:typed_data';

import 'package:dhsjakd/ble__manager/BLEHeartbeatPacket.dart';
import 'package:dhsjakd/ble__manager/BLEInterface.dart';
import 'package:dhsjakd/ble__manager/BLEStruct.dart';
import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEIOManager.dart';
import 'package:dhsjakd/ble__manager/ble_reformer/BleCheckCMDReformer.dart';
import 'package:dhsjakd/utls/DataConvertTool.dart';
import 'package:dhsjakd/utls/EventBus.dart';
import 'package:dhsjakd/utls/NumsType.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

class PawPlayManger implements ManagerDataInterface { 
  int   workMode;       // 工作模式  0 : hifi,  1 : sport
  int   playMode;       // 当前音乐播放模式
  int   playState;      // 播放器状态 0停止,1播放,2暂停
  int   batteryPercent; // 当前电池电量
  int   singleLock;     // 0  1是单曲锁定
  int   volnum;         // 设备音量
  int   bpm;            // 当前设置BPM
  bool  isBpmOn;        // Bpm 是否已经打开手动;
  int   mediaDbid;      // 当前歌曲id
  int   mediaDbpos;     // 当前歌曲pos
  int   mediaEx;        // 当前歌曲扩展
  int   playing_time;   // 当前秒数
  int   total_time;     // 总时间
  int   playinglist_id; // 当前播放列表 id;
  int   totalSize;      // RT_info 总大小
  bool  isNotSupport;   // 播放不支持;
  PAW_TagHeader   ex;   // 用于扩展


  Ble_RT_Info               ble_RT_Info;


  BleCheckCMDReformer       checkCMDReformer;

  BleIOManager              checkRT;
  BleIOManager              readRT;
  BleIOManager              realTimeControlRT;
  BleIOManager              realTimeControlVolnum;
  BleIOManager              realTimeControlWorkMode;
  BleIOManager              realTimeControlPlayMode;
  BleIOManager              realTimeControlSingleLock;
  BleIOManager              realTimeControlPlayState;
  BleIOManager              realTimeControlBpm;
  BleIOManager              realTimeControlTime;
  BleIOManager              realTimeControlPlayMedia;
  BleIOManager              realTimeControlPlayList;
  BleIOManager              checkNotSupport_songid;
  BleIOManager              readNotSupport_songid;
  BleIOManager              writeNotSupport_songid;

  factory PawPlayManger() => _getInstance();
  static PawPlayManger get instance => _getInstance();
  static PawPlayManger _instance;
  PawPlayManger._internal() {
    // 初始化
    // _subscribeiOSMessageChannel();
  }
  static PawPlayManger _getInstance() {
    if (_instance == null) {
      _instance = new PawPlayManger._internal();
    }
    return _instance;
  }



  void fillRTInfoWithData (Uint8List data) {
    bool isYes = false;
    int data_len = data.buffer.asByteData().getUint16(29);
    if (data_len < (36 - 4) || data_len > 10000 ) {
      return;
    }
    Uint16List pP3K_TagHeader;
    int num = sumBleRtInfoWithPinfo(data, data_len - 4);
    int len = data_len - 32;
    int tagHeader_index = getHeartTagData(data, len, PAW_BLE_RT_INFO_SUM);
    if (tagHeader_index != null) {
      int validationNum = data.buffer.asByteData().getUint16(tagHeader_index + 4 ,Endian.little);
        if (num == validationNum) {
            isYes = true;
        }
    }
    if (!isYes) {
        return;
    }

    ReadBuffer readBuffer = ReadBuffer(data.buffer.asByteData());

    this.workMode = readBuffer.getUint8();
    this.playMode = readBuffer.getUint8();
    this.playState = readBuffer.getUint8();
    this.singleLock = readBuffer.getUint8();readBuffer.getUint16();
    if (this.volnum != data.buffer.asByteData().getInt16(4, Endian.little)) {
        this.volnum = data.buffer.asByteData().getInt16(4, Endian.little);
        double volume = this.covertSystemVolumeFromPicoVolume(this.volnum);
    }
    int bpm = readBuffer.getUint16();readBuffer.getUint8List(8);
    this.bpm = bpm & (~PAW_BPM_SWITCH_ON);
    this.isBpmOn = bpm & PAW_BPM_SWITCH_ON == 1 ? true : false;
    this.mediaDbid = data.buffer.asByteData().getUint32(8, Endian.little);
    this.mediaDbpos = data.buffer.asByteData().getUint16(12, Endian.little);
    this.mediaEx = data.buffer.asByteData().getUint16(14, Endian.little);
    this.playing_time = (readBuffer.getUint32() / 1000).toInt();
    this.total_time = (readBuffer.getUint32() / 1000).toInt();
    this.playinglist_id = readBuffer.getUint32();
    this.isNotSupport = readBuffer.getUint16() & PLAY_ERROR_STATE_UNSUPPORT_SONG == 1 ? true : false;
    this.totalSize = readBuffer.getUint16();
    this.ex = PAW_TagHeader();
    this.ex.datatag = XUint16(data.buffer.asByteData(31, 4).getUint16(0));
    this.ex.datasize = XUint16(data.buffer.asByteData(33, 4).getUint16(0));
    // NSLog(@"workmode:%d",this.workMode);
    // NSLog(@"playState:%d",this.playState);
    // NSLog(@"playMode:%d",this.playMode);
    // NSLog(@"volnum:%d",this.volnum);
    // NSLog(@"playinglist_id:%d",this.playinglist_id);
    // NSLog(@"bpm:%d",this.bpm);
    // NSLog(@"bpm开关 %d",this.isBpmOn);

    // 推送通知
    eventBus.fire(PawHeartbeatEvent(isChange: true));
    
    if (this.isNotSupport) {
      this.checkNotSupport_songid = BleIOManager(this)
        ..setupObjectId(DEVICE_OBJECTID_UNSUPPORT_SONG_DBID)
        ..execute();
    }

  }

  //更改音量
  void setupVolnum (int num) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }
    // NSLog(@"setupVolnum -----------: %d",num);
    // NSLog(@"this.volnum -----------: %d",this.volnum);

    ByteData byteData = ByteData(2);
    byteData.setUint16(0, num);

    this.realTimeControlVolnum = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_VOLNUM)
      ..setupLength(2)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//更改工作模式 HIFI SPORT
  void setupWorkMode (int workMode) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }
    ByteData byteData = ByteData(1);
    byteData.setUint8(0, workMode);
    this.realTimeControlWorkMode = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_WORKMODE)
      ..setupLength(1)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//更改播放模式; 0 顺序 , 1 随机  ,3全盘播放;
  void setupPlayMode (int playMode) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }
    if (this.playMode == playMode) {
        return;
    }
    ByteData byteData = ByteData(1);
    byteData.setUint8(0, playMode);
    
    this.realTimeControlPlayMode = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_PLAYMODE)
      ..setupLength(1)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//设置单曲锁定 非零就是锁定;
  void setupSingleLock (int islock) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }
    ByteData byteData = ByteData(1);
    byteData.setUint8(0, islock);

    this.realTimeControlSingleLock = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_SINGLE_LOCK)
      ..setupLength(1)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//修改播放状态
  void setupPlayState (int playState) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }

    ByteData byteData = ByteData(1);
    byteData.setUint8(0, playState);

    this.realTimeControlPlayState = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_PLAYSTATE)
      ..setupLength(1)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//设置BPM
  void setupBpm (int bpm, bool isOn) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }
    
    if (isOn) {
        bpm |= PAW_BPM_SWITCH_ON;
    } else {
        bpm &= ~PAW_BPM_SWITCH_ON;
    }

    ByteData byteData = ByteData(2);
    byteData.setUint16(0, bpm);

    this.realTimeControlBpm = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(0x89) //CONTROL_OFFSET_BPMSET
      ..setupLength(2)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//设置当前播放秒数
  void setupTime (int time) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }

    ByteData byteData = ByteData(4);
    byteData.setUint32(0, time);
    
    this.realTimeControlTime = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_SEEK)
      ..setupLength(4)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//跳转指定歌曲 附加当前列表第几个
  void playMediaId(int dbid, int dbpos, int index) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }

    ByteData byteData = ByteData(8)
      ..setUint32(0, dbid)
      ..setUint16(4, dbpos)
      ..setUint16(6, index);

    this.realTimeControlPlayMedia = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_SELECTSONG)
      ..setupLength(8)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }

//跳转指定列表 第几个歌曲
  void playListId(int dbid, int dbpos, int index) {
    if (BleHeartbeatPacket().isProcess) {
        return;
    }

    ByteData byteData = ByteData(8)
      ..setUint32(0, dbid)
      ..setUint16(4, dbpos)
      ..setUint16(6, index);

    this.realTimeControlPlayList = BleIOManager(this)
      ..setupBtype(PAW_CMD_WRITE)
      ..setupOffset(CONTROL_OFFSET_SELECTPLIST)
      ..setupLength(8)
      ..setupSendData(byteData.buffer.asUint8List())
      ..execute();
  }



  @override
  failCallback(Error err, BleIOManager manager) {
    if (manager == this.checkRT) {
        
    } else if (manager == this.readRT) {
        
    } else if (manager == this.realTimeControlRT) {
        
    } else if (manager == this.realTimeControlVolnum) {
        
    } else if (manager == this.realTimeControlWorkMode) {
        
    } else if (manager == this.realTimeControlPlayMode) {
        
    } else if (manager == this.realTimeControlSingleLock) {
       
    } else if (manager == this.realTimeControlPlayState) {
        
    } else if (manager == this.realTimeControlBpm) {
        
    } else if (manager == this.realTimeControlTime) {
        
    } else if (manager == this.realTimeControlPlayMedia) {
        
    } else if (manager == this.realTimeControlPlayList) {
        
    } else if (manager == this.checkNotSupport_songid) {
        
    } else if (manager == this.readNotSupport_songid) {
        
    } else if (manager == this.writeNotSupport_songid) {
        
    }
    return null;
  }

  @override
  successCallback(Uint8List data, BleIOManager manager) {
    if (manager == this.checkRT) {
        
    } else if (manager == this.readRT) {
        
    } else if (manager == this.realTimeControlRT) {
        
    } else if (manager == this.realTimeControlVolnum) {
        
        
    } else if (manager == this.realTimeControlWorkMode) {
        
        
    } else if (manager == this.realTimeControlPlayMode) {
        
        
    } else if (manager == this.realTimeControlSingleLock) {
        
        
    } else if (manager == this.realTimeControlPlayState) {
        
        if (this.workMode == 1) {
            if (this.playState == 1) {
                // [[NSNotificationCenter defaultCenter] postNotificationName:PauseSport object:nil];
            }
        }
        
    } else if (manager == this.realTimeControlBpm) {
        
        
    } else if (manager == this.realTimeControlTime) {
        
        
        
    } else if (manager == this.realTimeControlPlayMedia) {
        
        // NSLog(@"");
    } else if (manager == this.realTimeControlPlayList) {
        
        // NSLog(@"");
    } else if (manager == this.checkNotSupport_songid) {
        int number = manager.fetchDataWithReformer(BleCheckCMDReformer());

        this.readNotSupport_songid = BleIOManager(this)
          ..setupLength(number)
          ..setupBtype(PAW_CMD_READ)
          ..setupObjectId(DEVICE_OBJECTID_UNSUPPORT_SONG_DBID)
          ..execute();
        
    } else if (manager == this.readNotSupport_songid) {
    
        Uint32List playlist = Uint32List.fromList(manager.rawData);
        
        List listArr = List();
        for (int i = 0; i < playlist[0]; i ++ ) {
            listArr.add(playlist[i + 1]);
        }
        
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"FoundThatCanNotPlaySongs" object:listArr];
        
        int tempKey = 1;
        ByteData byteData = ByteData(1);
        byteData.setUint8(0, tempKey);

        this.writeNotSupport_songid = BleIOManager(this)
          ..setupLength(1)
          ..setupBtype(PAW_CMD_WRITE)
          ..setupObjectId(DEVICE_OBJECTID_UNSUPPORT_SONG_DBID)
          ..execute();

    } else if (manager == this.writeNotSupport_songid) {
        
    }
    return null;
  }


  double covertSystemVolumeFromPicoVolume (int picoVolume) {
    double step = picoVolume.toDouble() / 36.0 * 17.0;
    return step * 0.0625;
}
  
}