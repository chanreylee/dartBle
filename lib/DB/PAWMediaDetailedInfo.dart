
class PawMediaDetailedInfo {
  int     pawId;

  int     songDbId;
  int     songDbPos;
  int     songDbPad;

  String  serverDbId;

  String  fileName;   //媒体文件名
  int     bpm;        //Bpm
  int     bitrate;    //比特率
  String  channel;    //声道;
  int     fileBit;    //文件大小;
  int     playedCount;//播放次数;
  int     duration;   //时长(秒)
  bool    isLike = false;

  String  artist;     //表演者
  String  songWriter; //词作者
  String  composer;   //曲作者
  String  album;      //专辑
  String  year;       //发布年份
  String  copyright;  //版权信息
  String  link;       //网址信息
  String  publisher;  //发行商

  String suffix;      //后缀;.MP3
  String quality;     //品质;

  bool isNotSupport = false;  //不能播放;

   Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    
    map['songDbId'] = songDbId;
    map['songDbPos'] = songDbPos;
    map['songDbPad'] = songDbPad;
    map['pawId'] = pawId;
    map['serverDbId'] = serverDbId;
    map['fileName'] = fileName;

    map['bpm'] = bpm;
    map['bitrate'] = bitrate;
    map['channel'] = channel;
    map['fileBit'] = fileBit;
    map['playedCount'] = playedCount;
    map['duration'] = duration;
    map['isLike'] = isLike ? 1 : 0;
    map['artist'] = artist;
    map['songWriter'] = songWriter;
    map['composer'] = composer;
    map['album'] = album;
    map['year'] = year;
    map['copyright'] = copyright;
    map['link'] = link;
    map['publisher'] = publisher;
    map['suffix'] = suffix;
    map['quality'] = quality;
    map['isNotSupport'] = isNotSupport ? 1 : 0;

    return map;
  }

  static PawMediaDetailedInfo fromMap(Map<String, dynamic> map) {
    PawMediaDetailedInfo mediaDetailedInfo = PawMediaDetailedInfo();
    
    mediaDetailedInfo.songDbId = map['songDbId'];
    mediaDetailedInfo.songDbPos = map['songDbPos'];
    mediaDetailedInfo.songDbPad = map['songDbPad'];
    mediaDetailedInfo.serverDbId = map['serverDbId'];
    mediaDetailedInfo.pawId = map['pawId'];
    mediaDetailedInfo.fileName = map['fileName'];

    mediaDetailedInfo.bpm = map['bpm'];
    mediaDetailedInfo.bitrate = map['bitrate'];
    mediaDetailedInfo.channel = map['channel'];
    mediaDetailedInfo.fileBit = map['fileBit'];
    mediaDetailedInfo.playedCount = map['playedCount'];
    mediaDetailedInfo.isLike = map['isLike'] == 1 ? true : false;
    mediaDetailedInfo.artist = map['artist'];
    mediaDetailedInfo.songWriter = map['songWriter'];
    mediaDetailedInfo.composer = map['composer'];
    mediaDetailedInfo.album = map['album'];
    mediaDetailedInfo.year = map['year'];
    mediaDetailedInfo.copyright = map['copyright'];
    mediaDetailedInfo.link = map['link'];
    mediaDetailedInfo.publisher = map['publisher'];
    mediaDetailedInfo.suffix = map['suffix'];
    mediaDetailedInfo.quality = map['quality'];
    mediaDetailedInfo.isNotSupport = map['isNotSupport'] == 1 ? true : false;

    return mediaDetailedInfo;
  }

  static List<PawMediaDetailedInfo> fromMapList(dynamic mapList) {
    List<PawMediaDetailedInfo> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  void qualityFromSuffix () {

    if (this.suffix == "dsf" || this.suffix == "dff" || this.suffix == "ISO") {
        this.quality = "DSD";
    } else if (this.suffix == "wav" || this.suffix == "flac" || this.suffix == "ape" || this.suffix == "aif" || this.suffix == "aiff" || this.suffix == "m4a") {
        this.quality = "SQ";
    } else if (this.suffix == "mp2" || this.suffix == "wma" || this.suffix == "aac" || this.suffix == "wv" || this.suffix == "ogg") {
        this.quality = "HQ";
    } else if (this.suffix == "mp3") {
        this.quality = "MP3";
    } else {
        this.quality = "未知品质";
    }
  }


  // static void updateDbOrCreate (PawMediaDetailedInfo pawMediaDetailedInfo) {

  //   Query query = Query(PAWMediaDetailedInfo).primaryKey([pawMediaDetailedInfo.songDbId]);

  //   query.all().then((List l) {
  //     if (l.length > 0) {
  //       query.update({
  //         "songDbPos":pawMediaDetailedInfo.songDbPos,
  //         "songDbPad":pawMediaDetailedInfo.songDbPad,
  //         "serverDbId":pawMediaDetailedInfo.serverDbId,
  //         "fileName":pawMediaDetailedInfo.fileName,
  //         "bpm":pawMediaDetailedInfo.bpm,
  //         "bitrate":pawMediaDetailedInfo.bitrate,
  //         "channel":pawMediaDetailedInfo.channel,
  //         "fileBit":pawMediaDetailedInfo.fileBit,
  //         "playedCount":pawMediaDetailedInfo.playedCount,
  //         "duration":pawMediaDetailedInfo.duration,
  //         "artist":pawMediaDetailedInfo.artist,
  //         "songWriter":pawMediaDetailedInfo.songWriter,
  //         "composer":pawMediaDetailedInfo.composer,
  //         "album":pawMediaDetailedInfo.album,
  //         "year":pawMediaDetailedInfo.year,
  //         "copyright":pawMediaDetailedInfo.copyright,
  //         "link":pawMediaDetailedInfo.link,
  //         "publisher":pawMediaDetailedInfo.publisher,
  //         "suffix":pawMediaDetailedInfo.suffix,
  //         "quality":pawMediaDetailedInfo.quality,
  //         "isNotSupport":pawMediaDetailedInfo.isNotSupport,
  //         });
  //     } else {
  //       Map newTable = {
  //                       "songDbId":pawMediaDetailedInfo.songDbId,
  //                       "songDbPos":pawMediaDetailedInfo.songDbPos,
  //                       "songDbPad":pawMediaDetailedInfo.songDbPad,
  //                       "serverDbId":pawMediaDetailedInfo.serverDbId,
  //                       "fileName":pawMediaDetailedInfo.fileName,
  //                       "bpm":pawMediaDetailedInfo.bpm,
  //                       "bitrate":pawMediaDetailedInfo.bitrate,
  //                       "channel":pawMediaDetailedInfo.channel,
  //                       "fileBit":pawMediaDetailedInfo.fileBit,
  //                       "playedCount":pawMediaDetailedInfo.playedCount,
  //                       "duration":pawMediaDetailedInfo.duration,
  //                       "artist":pawMediaDetailedInfo.artist,
  //                       "songWriter":pawMediaDetailedInfo.songWriter,
  //                       "composer":pawMediaDetailedInfo.composer,
  //                       "album":pawMediaDetailedInfo.album,
  //                       "year":pawMediaDetailedInfo.year,
  //                       "copyright":pawMediaDetailedInfo.copyright,
  //                       "link":pawMediaDetailedInfo.link,
  //                       "publisher":pawMediaDetailedInfo.publisher,
  //                       "suffix":pawMediaDetailedInfo.suffix,
  //                       "quality":pawMediaDetailedInfo.quality,
  //                       "isNotSupport":pawMediaDetailedInfo.isNotSupport,
  //                       };
  //       FlutterOrmPlugin.saveOrm(PAWMediaDetailedInfo, newTable);
  //     }
  //   });
  // }

}
