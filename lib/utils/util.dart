import 'dart:ui';

import 'package:faker/faker.dart';

class Vaccination {
  String vaccinationName;
  String chargeNr;
  DateTime vaccinationDate;
  String doctorSignature;
  String vaccinationDescription;

  Vaccination(this.vaccinationName, this.chargeNr, this.vaccinationDate, this.doctorSignature, this.vaccinationDescription);

  Vaccination.today(this.vaccinationName, this.chargeNr, this.doctorSignature, this.vaccinationDescription) : vaccinationDate = DateTime.now();
}

class Test {
  String testName;
  String testId;
  DateTime testDate;
  Status testStatus;
  String testDescription;

  Test(this.testName, this.testId, this.testDate, this.testStatus, this.testDescription);

  Test.newlyWithoutStatus(this.testName, this.testId, this.testDate, this.testDescription) : testStatus = Status.Pending;

  Test.newlyToday(this.testName, this.testId, this.testStatus, this.testDescription) : testDate = DateTime.now();

  Test.newlyTodayWithoutStatus(this.testName, this.testId, this.testDescription) : testDate = DateTime.now(), testStatus = Status.Pending;
}

class User {
  String userName;
  String userEmail;
  String userPassword;
  Role userRole;
  List<Vaccination> vaccinations;
  List<Test> tests;

  static User loggedInUser;

  User(this.userName, this.userEmail, this.userPassword, this.userRole);

  User.withData(this.userName, this.userEmail, this.userPassword, this.userRole, this.vaccinations, this.tests);

}

class PredefinedColors {
  static const lightOrange = const Color(0xffFFFACC);
  static const lightRed = const Color(0xffFEC3C3);
  static const lightGreen = const Color(0xffDEFFDB);
  static const primaryColor = const Color(0xff5D5FEF);
  static const textColor = const Color(0xff263238);
  static const accentWhite = const Color(0xfffafafa);
}

class LastUser {
  static String lastUser = "";
}

class TestData {
  static List<User> userListDb = [
    new User.withData('t', 't', 't', Role.Normal, generateVaccList(20), generateTestsList(10)),
    new User.withData('a', 'a', 'a', Role.Doctor, generateVaccList(20), generateTestsList(10))
  ];

  static List<User> familyUserDb = List<User>.generate(5, (int i) {
    return User.withData(faker.person.name(), faker.lorem.sentence(), faker.lorem.word(),
        Role.Normal, TestData.generateVaccList(10), TestData.generateTestsList(5));
  });

  static List<Vaccination> generateVaccList(int size) {
    return List<Vaccination>.generate(size, (int i) {
      return Vaccination(
          faker.food.dish(),
          faker.randomGenerator.decimal().toString(),
          faker.date.dateTime(),
          faker.person.name(),
          faker.lorem.sentence());
    });
  }

  static List<Test> generateTestsList(int size) {
    return List<Test>.generate(size, (int i) {
      return Test(
          faker.lorem.word(),
          faker.randomGenerator.decimal().toString(),
          faker.date.dateTime(),
          faker.randomGenerator.element(Status.values),
          faker.lorem.sentence());
    });
  }

  static User getMatchingUser(String email, String pw) {
    User matchingUser;
    userListDb.forEach((element) {
      if (matchingUser == null && element.userEmail.compareTo(email) == 0 &&
          element.userPassword.compareTo(pw) == 0) {
        matchingUser = element;
      }
    });
    return matchingUser;
  }
}

enum Login {
  NotLoggedIn,
  LoggedIn
}

enum Role {
  Normal,
  Doctor
}

enum Status {
  Good,
  Bad,
  Pending
}