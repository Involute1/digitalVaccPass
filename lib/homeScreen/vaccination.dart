import 'package:digital_vac_pass/database/vaccination_DAO.dart';
import 'package:digital_vac_pass/utils/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/custom_widgets.dart';

/// Vaccination overview
class MyVaccinationPage extends StatefulWidget {
  /// Vaccination overview
  const MyVaccinationPage(
      {Key key, this.selectedUser, this.isFloatingActionButtonVisible})
      : super(key: key);

  final User selectedUser;
  final bool isFloatingActionButtonVisible;

  @override
  State<StatefulWidget> createState() => _MyVaccinationPage();
}

class _MyVaccinationPage extends State<MyVaccinationPage> {
  @override
  void dispose() {
    super.dispose();
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
                child: FutureBuilder<List>(
                  future:
                      widget.isFloatingActionButtonVisible
                          ? VaccinationDAO.getAllVaccinesForUser(widget.selectedUser.userDbId)
                          : VaccinationDAO.getAllVaccinesForFamilyUser(widget.selectedUser.userDbId),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? new ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) => InkWell(
                                child: Column(
                              children: <Widget>[
                                Card(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    const SizedBox(height: 18),
                                                    Text(
                                                        snapshot.data[index]
                                                            .vaccinationName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1),
                                                  ]),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(height: 10),
                                                  Text('Datum: ' +
                                                      DateFormat('dd.MM.yyyy')
                                                          .format(snapshot
                                                              .data[index]
                                                              .vaccinationDate)),
                                                  const SizedBox(height: 8),
                                                  Text('ChargeNr: ' +
                                                      snapshot.data[index]
                                                          .chargeNr),
                                                  const SizedBox(height: 8),
                                                  Text('Arzt: ' +
                                                      snapshot.data[index]
                                                          .doctorSignature.toString()),
                                                  const SizedBox(height: 18),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            )),
                          )
                        : Center(child: const CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: myVisibleFloatingActionButton(
            context, widget.isFloatingActionButtonVisible),
      );
}
