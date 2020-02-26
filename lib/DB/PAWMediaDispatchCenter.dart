import 'dart:ffi';
import 'dart:math';

import 'package:dhsjakd/DB/PAWPlayerManger.dart';
import 'package:dhsjakd/DB/paw_db/db_keys.dart';
import 'package:dhsjakd/DB/paw_db/paw_db.dart';
import 'package:dhsjakd/DB/paw_db/paw_db.dart';
import 'package:dhsjakd/DB/paw_db/sql_table_data.dart';
import 'package:dhsjakd/ble__manager/BLECentralManager.dart';
import 'package:dhsjakd/ble__manager/BLEHeartbeatPacket.dart';
import 'package:dhsjakd/utls/EventBus.dart';

import 'PAWDevice.dart';
import 'PAWDirectory.dart';
import 'PAWLibrary.dart';
import 'PAWMediaDetailedInfo.dart';
import 'PAWMediaInfo.dart';
import 'PAWMediasDatabase.dart';

class PAWMediaDispatchCenter {

  PawMediaInfo currentMediaInfo;
  PawMediaDetailedInfo currentDetailedInfo;

  String currentSongName;
  int currentMediaIndex;
  int currentRandomMediaIndex;
  int currentDirectoryId;
  int currentDirectoryPos;

  PAWDevice currentDevice;
  PawLibrary currentLibrary;
  PawDirectory currentDirectory;
  List<PawMediaDetailedInfo> currentMediasDatabase = List();
  List<PawMediaDetailedInfo> currentListMeidaArr = List();
  List<PawMediaDetailedInfo> currentRandomListMeidaArr = List();
  List<PawMediaDetailedInfo> likeMedias = List();
  

  factory PAWMediaDispatchCenter() => _getInstance();
  static PAWMediaDispatchCenter get instance => _getInstance();
  static PAWMediaDispatchCenter _instance;
  PAWMediaDispatchCenter._internal() {
    // 初始化
    // _subscribeiOSMessageChannel();
    _loadLibraryFromDB();
    _subscribeHeartbeat();

  }
  static PAWMediaDispatchCenter _getInstance() {
    if (_instance == null) {
      _instance = new PAWMediaDispatchCenter._internal();
    }
    return _instance;
  }


  void _subscribeHeartbeat () {
    eventBus.on<PawHeartbeatEvent>().listen((event) async {
        if (event.isChange) {
          this.setCurrentMediaInfo = await this.getMediaInfo(PawPlayManger().mediaDbid);
          this.setCurrentDetailedInfo = await this.getMediaDetailedInfo(this.currentMediaInfo.songDbId, this.currentMediaInfo.songDbPos);
          this.setCurrentSongName = this.currentDetailedInfo.fileName;
          this.setCurrentDirectory = this.currentLibrary.directorys.where((directory) => directory.dicDbId == PawPlayManger().playinglist_id).first;
          this.setCurrentDirectoryId = PawPlayManger().playinglist_id;
          this.setCurrentDirectoryPos = this.currentDirectory.dicDbPos;
          this.setCurrentListMeidaArr = this.currentDirectory.mediaDetailedInfos;
          this.setCurrentMediaIndex = this.currentListMeidaArr.indexWhere((media) => media.songDbId == PawPlayManger().mediaDbid);
          this.setCurrentRandomListMeidaArr = this.getRandomListMeidaArr(this.currentListMeidaArr);
          this.setCurrentRandomMediaIndex = this.currentRandomListMeidaArr.indexWhere((media) => media.songDbId == PawPlayManger().mediaDbid);

          eventBus.fire(CurrentMediaInfoEvent(isChange: true));
        }
    });
  }

  List<PawMediaDetailedInfo> getRandomListMeidaArr (List<PawMediaDetailedInfo> meidaArr) {
    //当前列表 （随机）
        List<PawMediaDetailedInfo> randomList = List();
        Set<PawMediaDetailedInfo> randomSet = Set();
        if (meidaArr.length > 0) {
            do {
              int r = Random(DateTime.now().millisecondsSinceEpoch).nextInt(meidaArr.length) % meidaArr.length;
              randomSet.add(meidaArr[r]);
            } while (randomSet.length < meidaArr.length);
        }
        randomList.addAll(randomSet.toList());
        return randomList;
  }

  // 刷新所持有数据 从数据库中。
  Future<Void> _loadLibraryFromDB () async {
    this.currentLibrary = await this.loadMediasLibrary();
    this.currentLibrary.directorys = await this.getDirectorysWithLibraryId(libraryId: this.currentLibrary.pawId);
    for (var i = 0; i < this.currentLibrary.directorys.length; i++) {
      this.currentLibrary.directorys[i].medias = await this.getMediasWithDirectoryId(directoryId: this.currentLibrary.directorys[i].dicDbId);
    }
    for (var i = 0; i < this.currentLibrary.directorys.length; i++) {
      this.currentLibrary.directorys[i].mediaDetailedInfos = await this.getMediaDetailedInfosWithDirectoryId(this.currentLibrary.directorys[i].dicDbId);
    }
    this.currentLibrary.directorys.forEach((directory) {
      directory.mediaDetailedInfos.forEach((mediaDetailedInfo) {
          this.currentMediasDatabase.add(mediaDetailedInfo);
      });
    });
    print("初始完成");

    BleHeartbeatPacket().isCanStart = true;
    if (BleHeartbeatPacket().isCanStart) {
        BleHeartbeatPacket().start();
    }

  }

  // 加载当前设备的 歌曲库。
  Future<PawLibrary> loadMediasLibrary () async {
    List librarys = await PawDB.db.query(
      SqlTable.table_library,
      where: "pawId = ?",
      whereArgs: [BLECentralManager().connectedPeripheral.deviceId]
    );
    if (librarys.length > 0) {
        return PawLibrary.fromMap(librarys.first);
    } else {
        print("歌曲库 不存在");
        return null;
    }
  }
  
  // 获取当前 歌曲库的目录
  Future<List<PawDirectory>> getDirectorysWithLibraryId ({int libraryId}) async {
    List<PawDirectory> directoryList = List();
    List directorys = await PawDB.db.query(
      SqlTable.table_directory,
      where: "ownerId = ?",
      whereArgs: [this.currentLibrary.pawId]
    );
    if (directorys.length > 0) {
        directorys.forEach((dic) {
           PawDirectory directory = PawDirectory.fromMap(dic);
           directoryList.add(directory);
        });
    } else {
        print("歌曲库 不存在");
    }
    return directoryList;
  }

  //根据目录id 获取目录下所有 简化Media
  Future<List<PawMediaInfo>> getMediasWithDirectoryId ({int directoryId}) async {
    List<PawMediaInfo> mediaInfoList = List();
    List mediaInfos = await PawDB.db.query(
      SqlTable.table_mediaInfo,
      where: "directory_ownerId = ?",
      whereArgs: [directoryId]
    );
    if (mediaInfos.length > 0) {
        mediaInfos.forEach((value) {
           PawMediaInfo mediaInfo = PawMediaInfo.fromMap(value);
           mediaInfoList.add(mediaInfo);
        });
    } else {
        print("歌曲库 不存在");
    }
    return mediaInfoList;
  }

  //根据目录id 获取目录下所有 详细Media
Future<List<PawMediaDetailedInfo>> getMediaDetailedInfosWithDirectoryId (int directoryId) async {
    List<PawMediaDetailedInfo> mediaList = List();

    PawDirectory directory = this.currentLibrary.directorys.where((item) => item.dicDbId == directoryId).first;

    directory.medias.forEach((value) async {
      PawMediaDetailedInfo mediaDetailedInfo = await this.getMediaDetailedInfo(value.songDbId, value.songDbPos);
      mediaList.add(mediaDetailedInfo);
    });

    return mediaList;
  }

  // 根据歌曲id 获取 当前所在目录~、
  Future<PawDirectory> getMediaDirectoryWithSongId (int songId) async {

    PawDirectory directory = this.currentLibrary.directorys.where((item) {
      
      bool find = false;
      for (var i = 0; i < item.medias.length; i++) {
          if (item.medias[i].songDbId == songId) {
            find = true;
            break;
          }
      }
      return find;
    }).first;

    return directory;

  }

  // 根据歌曲 id ，pos  获取歌曲详细。 
  Future<PawMediaDetailedInfo> getMediaDetailedInfo (int songId, int songPos) async {

    List mediaDetailedInfos = await PawDB.db.query(
      SqlTable.table_mediaDetailedInfo,
      where: "songDbId = ? and songDbPos = ? and pawId = ?",
      whereArgs: [songId, songPos, this.currentLibrary.pawId]
    );
    if (mediaDetailedInfos.length > 0) {
        return PawMediaDetailedInfo.fromMap(mediaDetailedInfos.first);
    } else {
        print("歌曲不存在");
        return null;
    }
  }

  // 根据歌曲 id  获取歌曲简化。 
  Future<PawMediaInfo> getMediaInfo (int songId) async {

    List medias = await PawDB.db.query(
      SqlTable.table_mediaInfo,
      where: "songDbId = ? and pawId = ?",
      whereArgs: [songId, this.currentLibrary.pawId]
    );
    if (medias.length > 0) {
        return PawMediaInfo.fromMap(medias.first);
    } else {
        print("歌曲不存在");
        return null;
    }
  }

  void set setCurrentSongName (String currentSongName) {
    this.currentSongName = currentSongName;
  }

  void set setCurrentMediaIndex (int currentMediaIndex) {
    this.currentMediaIndex = currentMediaIndex;
  }

  void set setCurrentRandomMediaIndex (int currentRandomMediaIndex) {
    this.currentRandomMediaIndex = currentRandomMediaIndex;
  }

  void set setCurrentDirectoryId (int currentDirectoryId) {
    this.currentDirectoryId = currentDirectoryId;
  }

  void set setCurrentDirectoryPos (int currentDirectoryPos) {
    this.currentDirectoryPos = currentDirectoryPos;
  }

  void set setCurrentDevice (PAWDevice currentDevice) {
    this.currentDevice = currentDevice;
  }

  void set setCurrentLibrary (PawLibrary currentLibrary) {
    this.currentLibrary = currentLibrary;
  }

  void set setCurrentDirectory (PawDirectory currentDirectory) {
    this.currentDirectory = currentDirectory;
  }

  void set setCurrentMediaInfo (PawMediaInfo currentMediaInfo) {
    this.currentMediaInfo = currentMediaInfo;
  }

  void set setCurrentDetailedInfo (PawMediaDetailedInfo currentDetailedInfo) {
    this.currentDetailedInfo = currentDetailedInfo;
  }

  void set setCurrentListMeidaArr (List<PawMediaDetailedInfo> currentListMeidaArr) {
    this.currentListMeidaArr = currentListMeidaArr;
  }

  void set setCurrentRandomListMeidaArr (List<PawMediaDetailedInfo> currentRandomListMeidaArr) {
    this.currentRandomListMeidaArr = currentRandomListMeidaArr;
  }

  void set setLikeMedias (List<PawMediaDetailedInfo> likeMedias) {
    this.likeMedias = likeMedias;
  }


}