


import 'PAWMediaInfo.dart';

class PawLikeDirectory {
  String useId;

  List<PawMediaInfo> medias = List();

  // static void updateDbOrCreate (PawLikeDirectory pawLikeDirectory) {

  //   Query query = Query(PAWLikeDirectory).primaryKey([pawLikeDirectory.useId]);

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
  //       FlutterOrmPlugin.saveOrm(PAWLikeDirectory, newTable);
  //     }
  //   });
  // }
}