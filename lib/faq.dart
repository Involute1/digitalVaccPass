import 'package:flutter/material.dart';
import 'appBar.dart';
import 'drawer.dart';

class MyFaqPage extends StatefulWidget {
  MyFaqPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyFaqPageState createState() => _MyFaqPageState();
}

class _MyFaqPageState extends State<MyFaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyHeader(),
      ),
      body: Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "About",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Card(
                margin: EdgeInsets.all(20),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                      title: Column(
                          children: [
                            SizedBox(height: 18),
                            Text("Ist der Impfpass sicher?", style: Theme.of(context).textTheme.bodyText1),
                          ]
                      ),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                              "Ja, diese App wurde mit Professoren und Experten entwickelt, die sich extrem gut auskennen mit der Materie",
                              textAlign: TextAlign.left),
                          SizedBox(height: 18),
                        ],
                      ))
                ])),
            Card(
                margin: EdgeInsets.all(20),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  ListTile(
                      title: Column(
                          children: [
                            SizedBox(height: 18),
                            Text("Wie schnell sehe ich neue Impfungen?", style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.left),
                          ]
                      ),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                              "Innerhalb weniger Sekunden nach Scannung des QR-Codes ist die Impfung durch den Arzt übertragen.",
                              textAlign: TextAlign.left),
                          SizedBox(height: 18),
                        ],

                      ))
                ])),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
