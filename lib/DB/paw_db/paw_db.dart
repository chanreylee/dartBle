import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'sql_table_data.dart';

class PawDB {
  static final PawDB _instance = new PawDB.internal();

  factory PawDB() => _instance;

  PawDB.internal();

  static Database db;

  Future<Database> get getNewDb async {
    if (db != null) {
      return db;
    }
    db = await init();

    return db;
  }

  //初始化数据库
  Future init() async {
    //Get a location using getDatabasesPath
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'pawone.db');
    print(path);
    try {
      db = await openDatabase(path);
    } catch (e) {
      print("Error $e");
    }

    bool tableIsRight = await this.checkTableIsRight();

    if (!tableIsRight) {
      // 关闭上面打开的db，否则无法执行open
      db.close();
      //表不完整
      // Delete the database
      await deleteDatabase(path);

      db = await openDatabase(path,
          version: 1,
          onCreate: _onCreate,
          onOpen: _onOpen,
          onUpgrade: _onUpgrade,
          onDowngrade: onDatabaseDowngradeDelete);
    } else {
      print("Opening existing database");
    }
  }

  // 获取数据库中所有的表
  Future<List> getTables() async {
    if (db == null) {
      return Future.value([]);
    }
    List tables = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    List<String> targetList = [];
    tables.forEach((item) {
      targetList.add(item['name']);
    });
    return targetList;
  }

  // 检查数据库中, 表是否完整, 在部份android中, 会出现表丢失的情况
  Future checkTableIsRight() async {
    List<String> expectTables = [
      'library',
      'directory',
      'mediaInfo',
      'mediaDetailedInfo',
      'device'
    ]; //将项目中使用的表的表名添加集合中

    List<String> tables = await getTables();

    for (int i = 0; i < expectTables.length; i++) {
      if (!tables.contains(expectTables[i])) {
        return false;
      }
    }
    return true;
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    var batch = db.batch();
    _createTableCompanyV1(batch);
    // _updateTableCompanyV1toV2(batch);
    await batch.commit();
    print("Table is created");
  }

  void _onOpen(Database db) async {
    print('new db opened');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    if (oldVersion < 2) {
      _updateTableCompanyV1toV2(batch);
    }
    await batch.commit();
  }

  ///创建数据库--初始版本
  void _createTableCompanyV1(Batch batch) {
    // "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY,$columnGoodsId TEXT,$columnGoodsName TEXT, $columnCount INTEGER,$columnPrice REAL,$columnImages TEXT,$columnOldPrice REAL)",
    batch.execute(SqlTable.sql_createTable_library);
    batch.execute(SqlTable.sql_createTable_directory);
    batch.execute(SqlTable.sql_createTable_mediaInfo);
    batch.execute(SqlTable.sql_createTable_mediaDetailedInfo);
    batch.execute(SqlTable.sql_createTable_device);
  }

  ///更新数据库Version: 1->2.
  ///添加个新字段 或者 大更新，
  void _updateTableCompanyV1toV2(Batch batch) {
    // batch.execute('ALTER TABLE $tableName ADD $columnIsSelect BOOL');
  }
}
