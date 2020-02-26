
import 'PAWDirectory.dart';


class PawLibrary {
  int pawId;
  int listCount;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['pawId'] = pawId;
    map['listCount'] = listCount;
    return map;
  }

  static PawLibrary fromMap(Map<String, dynamic> map) {
    PawLibrary library = PawLibrary();
    library.pawId = map['pawId'];
    library.listCount = map['listCount'];
    
    return library;
  }

  List<PawDirectory> directorys = List();
  
  List<int> _directorys = List();

  // static void updateDbOrCreate (PawLibrary pawLibrary) {

  //   Query query = Query(PAWLibrary).primaryKey([pawLibrary.pawId]);

  //   query.all().then((List l) {
  //     if (l.length > 0) {
  //       query.update({"directorys":pawLibrary._directorys});
  //     } else {
  //       Map newTable = {"pawId":pawLibrary.pawId};
  //       FlutterOrmPlugin.saveOrm(PAWLibrary, newTable);
  //     }
  //   });
  //   // Query("PawLibrary").primaryKey([pawLibrary.pawId]).update({"directorys":pawLibrary._directorys});
  // }

}