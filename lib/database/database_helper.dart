import 'package:sqflite/sqflite.dart';

import '../utils/util.dart';

/// Database Helper
class DatabaseHelper {
  /// Database Helper
  DatabaseHelper.privateConstructor();

  static final DatabaseHelper _instance = DatabaseHelper.privateConstructor();

  factory DatabaseHelper() => _instance;
  static Database _db;

  static const String userTable = 'USER';
  static const String familyTable = 'FAMILY_MEMBER';
  static const String vaccinesTable = 'VACCINES';
  static const String testsTable = 'TESTS';
  static const String statisticTable = 'STATISTIC';

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    //io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //String path = join(documentsDirectory.path, "digital_vaccination_pass.db");
    final Database _db = await openDatabase("digital_vaccination_passV4.db",
        version: 1, onCreate: _onCreate);
    return _db;
  }

  _onCreate(Database db, int version) async {
    //id, name, email, role, pw
    const String userTable =
        'CREATE TABLE USER (USER_ID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'USER_NAME TEXT, USER_EMAIL TEXT, USER_ROLE TEXT, PASSWORD TEXT)';
    // id, name, email
    const String familyTable =
        'CREATE TABLE FAMILY_MEMBER (FAMILY_MEMBER_ID INTEGER PRIMARY KEY '
        'AUTOINCREMENT, FAMILY_MEMBER_NAME TEXT, FAMILY_MEMBER_EMAIL TEXT)';
    // name, chargeNr, date, docSig, descr, userId, familyId
    const String vaccinesTable =
        'CREATE TABLE VACCINES (VACCINES_ID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'VACCINE_NAME TEXT, CHARGE_NR TEXT, VACCINE_DATE TEXT, DOCTOR_SIGNATURE'
        ' TEXT, VACCINE_DESCRIPTION TEXT, USER_ID INTEGER, FAMILY_ID INTEGER)';
    // name, id, date, status, descr, userId, familyId
    const String testsTable =
        'CREATE TABLE TESTS (TEST_ID INTEGER PRIMARY KEY AUTOINCREMENT, '
        'TEST_NAME TEXT, TEST_ID_NR TEXT, TEST_DATE TEXT, TEST_STATUS TEXT, '
        'TEST_DESCRIPTION TEXT, USER_ID INTEGER, FAMILY_ID INTEGER)';
    //
    const String statisticTable = 'CREATE TABLE STATISTIC ()';

    await db.execute(userTable);
    await db.execute(familyTable);
    await db.execute(vaccinesTable);
    await db.execute(testsTable);
    // await db.execute(statisticTable);
    _initTestData(db);
  }

  _initTestData(Database db) async {
    final Batch batch = db.batch();
    TestData.userListDb.forEach(
        (element) => {batch.insert(DatabaseHelper.userTable, element.toMap())});
    await batch.commit(noResult: true);

    final Batch familyBatch = db.batch();
    TestData.familyUserDb.forEach((element) {
      familyBatch.insert(
          DatabaseHelper.familyTable, element.toFamilyMemberMap());
    });
    await familyBatch.commit(noResult: true);

    final Batch vaccBatch = db.batch();
    for (int i = 1; i < 6; i++) {
      if (i < 3) {
        TestData.vaccinationListDb.forEach((element) {
          element.userId = i;
          element.familyId = null;
          vaccBatch.insert(DatabaseHelper.vaccinesTable, element.toMap());
        });
      }
      TestData.vaccinationListDb.forEach((element) {
        element.userId = null;
        element.familyId = i;
        vaccBatch.insert(DatabaseHelper.vaccinesTable, element.toMap());
      });
    }
    await vaccBatch.commit(noResult: true);

    final Batch testBatch = db.batch();
    for (int i = 1; i < 6; i++) {
      if (i < 3) {
        TestData.testsListDb.forEach((element) {
          element.userId = i;
          element.familyId = null;
          testBatch.insert(DatabaseHelper.testsTable, element.toMap());
        });
      }
      TestData.testsListDb.forEach((element) {
        element.userId = null;
        element.familyId = i;
        testBatch.insert(DatabaseHelper.testsTable, element.toMap());
      });
    }
    await testBatch.commit(noResult: true);
  }
}