import 'package:sqflite/sqflite.dart';

import '../utils/test.dart';
import 'database_helper.dart';

/// DatabaseHelper
final DatabaseHelper con = DatabaseHelper();

/// TestDAO
class TestDAO {
  /// Add test
  static Future<int> create(
      String testName,
      String testIdNr,
      DateTime testDate,
      Status testStatus,
      String testDescription,
      int userId,
      int familyId) async {
    final Database dbClient = await con.db;
    final Test insertTest = Test.forDb(familyId, testDate, testDescription,
        testIdNr, testName, testStatus, userId);
    final int id =
        await dbClient.insert(DatabaseHelper.vaccinesTable, insertTest.toMap());
    return id;
  }

  /// Get all tests for current user
  static Future<List<Test>> getAllTestsForUser(int userId) async {
    final Database dbClient = await con.db;
    final List<Map<String, Object>> list = await dbClient.rawQuery(
        'SELECT * FROM ${DatabaseHelper.testsTable} WHERE USER_ID = ?',
        [userId]);

    final List<Test> vaccList = list.isNotEmpty
        ? list.map((Map<String, Object> e) => Test.fromMap(e)).toList()
        : List<Test>.empty();

    return vaccList;
  }

  /// Get all tests for specific family member
  static Future<List<Test>> getAllTestsForFamilyUser(int familyId) async {
    final Database dbClient = await con.db;
    final List<Map<String, Object>> list = await dbClient.rawQuery(
        'SELECT * FROM ${DatabaseHelper.testsTable} WHERE FAMILY_ID = ?',
        [familyId]);

    final List<Test> vaccList = list.isNotEmpty
        ? list.map((Map<String, Object> e) => Test.fromMap(e)).toList()
        : List<Test>.empty();

    return vaccList;
  }
}
