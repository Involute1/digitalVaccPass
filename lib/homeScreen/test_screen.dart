import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../database/test_dao.dart';
import '../utils/custom_widgets.dart';
import '../utils/test.dart';
import '../utils/user.dart';
import '../utils/util.dart';

/// Test results
class MyTestPage extends StatefulWidget {
  /// Test results
  const MyTestPage(
      {Key key, this.selectedUser, this.isFloatingActionButtonVisible})
      : super(key: key);

  final User selectedUser;
  final bool isFloatingActionButtonVisible;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<User>('selectedUser_testresult', selectedUser));
    properties.add(DiagnosticsProperty<bool>(
        'isFloatingActionButtonVisible_testresult',
        isFloatingActionButtonVisible));
  }

  @override
  _MyTestPageState createState() => _MyTestPageState();
}

class _MyTestPageState extends State<MyTestPage> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> testNotEmpty() async {
    final List<Test> tests = widget.isFloatingActionButtonVisible
        ? await TestDAO.getAllTestsForUser(widget.selectedUser.userDbId)
        : await TestDAO.getAllTestsForFamilyUser(
            widget.selectedUser.familyDbId);
    return Future<bool>.value(tests.isEmpty);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.selectedUser.userName,
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center),
              const SizedBox(height: 25),
              Expanded(
                  child: FutureBuilder<bool>(
                      future: testNotEmpty(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                PredefinedColors.primaryColor),
                          );
                        } else if (snapshot.data == true) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Visibility(
                                    visible: snapshot.data,
                                    child: Text(
                                        AppLocalizations.of(context)
                                            .noTestsAvailable,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24,
                                            color: PredefinedColors
                                                .backgroundTextColor))),
                              ]);
                        } else {
                          return FutureBuilder<List<Test>>(
                            future: widget.isFloatingActionButtonVisible
                                ? TestDAO.getAllTestsForUser(
                                    widget.selectedUser.userDbId)
                                : TestDAO.getAllTestsForFamilyUser(
                                    widget.selectedUser.familyDbId),
                            builder:
                                (BuildContext context,
                                        AsyncSnapshot snapshot) =>
                                    snapshot.hasData
                                        ? ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder:
                                                (BuildContext context,
                                                        int index) =>
                                                    Column(
                                                      children: <Widget>[
                                                        Card(
                                                            color: snapshot
                                                                        .data[
                                                                            index]
                                                                        .testStatus ==
                                                                    Status
                                                                        .pending
                                                                ? PredefinedColors
                                                                    .lightOrange
                                                                : snapshot
                                                                            .data[
                                                                                index]
                                                                            .testStatus ==
                                                                        Status
                                                                            .good
                                                                    ? PredefinedColors
                                                                        .lightGreen
                                                                    : PredefinedColors
                                                                        .lightRed,
                                                            child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Expanded(
                                                                      child:
                                                                          Column(
                                                                    children: <
                                                                        Widget>[
                                                                      ListTile(
                                                                        title:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            const SizedBox(height: 18),
                                                                            Text(
                                                                              snapshot.data[index].testName,
                                                                              style: Theme.of(context).textTheme.bodyText1,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        subtitle:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            const SizedBox(height: 10),
                                                                            Text(AppLocalizations.of(context).date +
                                                                                DateFormat('dd.MM.yyyy').format(snapshot.data[index].testDate)),
                                                                            const SizedBox(height: 8),
                                                                            Text(AppLocalizations.of(context).testID +
                                                                                snapshot.data[index].testIdNr.toString()),
                                                                            const SizedBox(height: 8),
                                                                            Text(snapshot.data[index].testStatus.toString().substring(snapshot.data[index].testStatus.toString().indexOf('.') +
                                                                                1)),
                                                                            const SizedBox(height: 18),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ))
                                                                ])),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ))
                                        : const Center(
                                            child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                PredefinedColors.primaryColor),
                                          )),
                          );
                        }
                      }))
            ],
          ),
        ),
        floatingActionButton: myVisibleFloatingActionButtonForQrScanner(
            context, widget.isFloatingActionButtonVisible, 'TEST'),
      );
}
