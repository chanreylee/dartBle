class SqlTable{

  static final String table_library = "library";
  static final String table_directory = "directory";
  static final String table_mediaInfo = "mediaInfo";
  static final String table_mediaDetailedInfo = "mediaDetailedInfo";
  static final String table_device = "device";
  

  static final String sql_createTable_library = """
      CREATE TABLE library (
        pawId INTEGER NOT NULL PRIMARY KEY,
        listCount INTEGER default(0)
      );
    """;

  //// ownerId PAWONE+"_"+PAWLibrary
  static final String sql_createTable_directory = """
    CREATE TABLE directory (
      dicDbId INTEGER NOT NULL PRIMARY KEY, 
      dicDbPos INTEGER default(0),
      dicDbPad INTEGER default(0),
      dicName TEXT,
      ownerId INTEGER
    );
  """;

  static final String sql_createTable_mediaInfo = """
    CREATE TABLE mediaInfo (
      songDbId INTEGER PRIMARY KEY, 
      songDbPos INTEGER default(0),
      songDbPad INTEGER default(0),
      fileName TEXT,
      pawId INTEGER NOT NULL, 
      directory_ownerId INTEGER ,
      like_ownerId INTEGER
    );
  """;


  static final String sql_createTable_mediaDetailedInfo = """
    CREATE TABLE mediaDetailedInfo (
      
      songDbId INTEGER PRIMARY KEY NOT NULL, 
      songDbPos INTEGER default(0),
      songDbPad INTEGER default(0),
      pawId INTEGER NOT NULL, 
      fileName TEXT,
      serverDbId TEXT,
      bpm INTEGER,
      bitrate INTEGER,
      channel TEXT,
      fileBit INTEGER,
      playedCount INTEGER,
      duration INTEGER,
      isLike INTEGER,
      artist TEXT,

      songWriter TEXT,
      composer TEXT,
      album TEXT,
      year TEXT,
      copyright TEXT,
      link TEXT,
      publisher TEXT,
      suffix TEXT,
      quality TEXT,
      isNotSupport INTEGER

    );
  """;

  static final String sql_createTable_device = """
    CREATE TABLE device (
      deviceId INTEGER PRIMARY KEY NOT NULL, 
      deviceName TEXT  ,
      deviceNickName TEXT,
      time INTEGER,
      ephemerisName TEXT,
      key INTEGER,
      fileCount INTEGER,
      diskCapacity TEXT,
      remainCapacity TEXT,
      devModel TEXT,
      serialNo TEXT,
      firewareVersion TEXT,
      bleVersion TEXT

    );
  """;

}