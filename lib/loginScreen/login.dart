import 'package:digital_vac_pass/statistics.dart';
import 'package:digital_vac_pass/utils/util.dart';

import '../homeScreen/home.dart';
import 'register.dart';
import '../drawer.dart';
import 'package:flutter/material.dart';
import '../appBar.dart';
import 'forgotpassword.dart';

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final myEmailTextController = TextEditingController();
  final myPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool checkIfUserExists(String email, String pw) {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    bool exists = false;
    TestData.userListDb.forEach((element) {
      if (!exists) {
        if (element.userEmail.compareTo(email) == 0 &&
            element.userPassword.compareTo(pw) == 0) {
          exists = true;
        }
      }
    });
    return exists;
  }

  @override
  void dispose() {
    myEmailTextController.dispose();
    myPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyHeader(),
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Login",
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.left),
                SizedBox(height: 25),
                TextFormField(
                  controller: myEmailTextController,
                  autofocus: true,
                  cursorColor: Theme.of(context).primaryColorLight,
                  decoration: new InputDecoration(
                    labelText: "E-Mail",
                    fillColor: Theme.of(context).accentColor,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                      borderSide: new BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 3.0,
                      ),
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                      borderSide: new BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 3.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 3.0,
                        )),
                    labelStyle: new TextStyle(
                        color: Theme.of(context).primaryColorLight),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isNotEmpty) {
                      return null;
                    } else {
                      return 'Darf nicht leer sein.';
                    }
                  },
                ),
                SizedBox(height: 25),
                TextFormField(
                  controller: myPasswordController,
                  cursorColor: Theme.of(context).primaryColorLight,
                  decoration: new InputDecoration(
                    labelText: "Passwort",
                    fillColor: Theme.of(context).accentColor,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                      borderSide: new BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 3.0,
                      ),
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                      borderSide: new BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 3.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 3.0,
                        )),
                    labelStyle: new TextStyle(
                        color: Theme.of(context).primaryColorLight),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value.isNotEmpty) {
                      return null;
                    } else {
                      return 'Darf nicht leer sein.';
                    }
                  },
                ),
                SizedBox(height: 25),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    primary: Theme.of(context).primaryColorLight,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyForgotPasswordPage()));
                  },
                  child: Row(
                    children: <Widget>[
                      Flexible(child: const Text('Passwort vergessen?')),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(height: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (checkIfUserExists(myEmailTextController.text,
                          myPasswordController.text)) {
                        User.loggedInUser = TestData.getMatchingUser(
                            myEmailTextController.text,
                            myPasswordController.text);
                        if (MyDrawer.getDoctor(myEmailTextController.text)) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyStatisticPage()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  MyHomeScreenPage(selectedTabIndex: 0)));
                        }

                        LastUser.lastUser = myEmailTextController.text;
                      } else if (myEmailTextController.text != "" &&
                          myPasswordController.text != "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.all(20.0),
                            elevation: 10,
                            content: const Text(
                                'E-Mail und Passwort stimmen nicht überein.'),
                            duration: const Duration(milliseconds: 3000),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        );
                      }
                    },
                    label: Flexible(
                        child: Text('Einloggen',
                            style: new TextStyle(fontSize: 20))),
                    icon: Icon(Icons.login),
                  ),
                ),
                SizedBox(height: 25),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(height: 60),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      primary: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 3.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyRegisterPage()));
                    },
                    label: Flexible(
                        child: Text('Registrieren',
                            style: Theme.of(context).textTheme.bodyText2)),
                    icon: Icon(
                      Icons.how_to_reg,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
