
import 'package:dhsjakd/DB/PAWMediaDetailedInfo.dart';
import 'package:dhsjakd/DB/PAWMediaInfo.dart';

class PawDirectory {
  
  
  

  int dicDbId;
  int dicDbPos;
  int dicDbPad;
  String dicName;
  int ownerId;

  List<PawMediaInfo> medias = List<PawMediaInfo>();  //扩展属性
  List<PawMediaDetailedInfo> mediaDetailedInfos = List<PawMediaDetailedInfo>();

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['dicDbId'] = dicDbId;
    map['dicDbPos'] = dicDbPos;
    map['dicDbPad'] = dicDbPad;
    map['dicName'] = dicName;
    map['ownerId'] = ownerId;
    return map;
  }

  static PawDirectory fromMap(Map<String, dynamic> map) {
    PawDirectory directory = PawDirectory();
    directory.dicDbId = map['dicDbId'];
    directory.dicDbPos = map['dicDbPos'];
    directory.dicDbPad = map['dicDbPad'];
    directory.dicName = map['dicName'];
    directory.ownerId = map['ownerId'];
    return directory;
  }

  static List<PawDirectory> fromMapList(dynamic mapList) {
    List<PawDirectory> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }


  // static void updateDbOrCreate (PawDirectory pawDirectory) {

  //   Query query = Query(PAWDirectory).primaryKey([pawDirectory.dicDbId]);

  //   query.all().then((List l) {
  //     if (l.length > 0) {

  //       query.update({
  //         "dicDbPos":pawDirectory.dicDbPos,
  //         "dicDbPad":pawDirectory.dicDbPad,
  //         "dicName":pawDirectory.dicName
  //         });
  //     } else {
  //       Map newTable = {
  //                       "dicDbId":pawDirectory.dicDbId,
  //                       "dicDbPos":pawDirectory.dicDbPos,
  //                       "dicDbPad":pawDirectory.dicDbPad,
  //                       "dicName":pawDirectory.dicName
  //                       };
  //       FlutterOrmPlugin.saveOrm(PAWDirectory, newTable);
  //     }
  //   });
  // }

}