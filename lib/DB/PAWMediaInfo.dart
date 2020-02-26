

import 'PAWDirectory.dart';
import 'PAWLikeDirectory.dart';

class PawMediaInfo {
  int songDbId;
  int songDbPos;
  int songDbPad;
  String fileName;

  int directory_ownerId;
  int like_ownerId;
  int pawId;

  PawDirectory directoryOwners;
  PawLikeDirectory likeOwners;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['songDbId'] = songDbId;
    map['songDbPos'] = songDbPos;
    map['songDbPad'] = songDbPad;
    map['fileName'] = fileName;
    map['directory_ownerId'] = directory_ownerId;
    map['like_ownerId'] = like_ownerId;
    map['pawId'] = pawId;

    return map;
  }

  static PawMediaInfo fromMap(Map<String, dynamic> map) {
    PawMediaInfo mediaInfo = PawMediaInfo();
    mediaInfo.songDbId = map['songDbId'];
    mediaInfo.songDbPos = map['songDbPos'];
    mediaInfo.songDbPad = map['songDbPad'];
    mediaInfo.fileName = map['fileName'];
    mediaInfo.directory_ownerId = map['directory_ownerId'];
    mediaInfo.like_ownerId = map['like_ownerId'];
    mediaInfo.pawId = map['pawId'];
    return mediaInfo;
  }

  static List<PawMediaInfo> fromMapList(dynamic mapList) {
    List<PawMediaInfo> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  // static void updateDbOrCreate (PawMediaInfo pawMediaInfo) {

  //   Query query = Query(PAWMediaInfo).primaryKey([pawMediaInfo.songDbId]);

  //   query.all().then((List l) {
  //     if (l.length > 0) {
  //       query.update({
  //         "songDbPos":pawMediaInfo.songDbPos,
  //         "songDbPad":pawMediaInfo.songDbPad,
  //         "directory_ownerId":pawMediaInfo.directory_ownerId,
  //         "like_ownerId":pawMediaInfo.like_ownerId
  //         });
  //     } else {
  //       Map newTable = {
  //                       "songDbId":pawMediaInfo.songDbId,
  //                       "songDbPos":pawMediaInfo.songDbPos,
  //                       "songDbPad":pawMediaInfo.songDbPad,
  //                       "directory_ownerId":pawMediaInfo.directory_ownerId,
  //                       "like_ownerId":pawMediaInfo.like_ownerId
  //                       };
  //       FlutterOrmPlugin.saveOrm(PAWMediaInfo, newTable);
  //     }
  //   });
  // }
}