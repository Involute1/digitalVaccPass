import 'dart:ffi';
import 'dart:io';

import 'package:digital_vac_pass/database/test_dao.dart';
import 'package:digital_vac_pass/familyScreen/family.dart';
import 'package:digital_vac_pass/homeScreen/test_screen.dart';
import 'package:digital_vac_pass/utils/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:ninja/ninja.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

import '../database/vaccination_dao.dart';
import '../homeScreen/vaccination_screen.dart';
import '../utils/app_bar.dart';
import '../utils/rsa.dart';
import '../utils/user.dart';

/// QR Scanner
class QRViewExample extends StatefulWidget {
  /// QR Scanner
  const QRViewExample({Key key, this.calledFrom}) : super(key: key);

  final String calledFrom;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<String>('calledFrom_qr_scanner', calledFrom));
  }

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode result;
  String barcodeString;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const MyHeader(),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildQrView(context)),
          ],
        ),
      );

  Widget _buildQrView(BuildContext context) {
    final double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).accentColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 15,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final RSAPrivateKey privateKey = RSAPrivateKey.fromPEM(privateKeyPem);
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      sleep(const Duration(milliseconds: 10));
      setState(() {
        switch (widget.calledFrom) {
          case 'VACCINE':
            _calledFromVaccine(privateKey.decryptToUtf8(scanData));
            break;
          case 'TEST':
            _calledFromTest(scanData);
            break;
          case 'FAMILY':
            _calledFromFamily(scanData);
            break;
          default:
            break;
        }
      });
    });
  }

  void _calledFromVaccine(String result) {
    if (result != null) {
      if (barcodeString.contains('VACCINE:') &&
          barcodeString.contains('CHARGENR:') &&
          barcodeString.contains('DATE:') &&
          barcodeString.contains('DOCTOR:')) {
        final String vaccineName = barcodeString.substring(
            barcodeString.indexOf('VACCINE:') + 8,
            barcodeString.indexOf('\r\nCHARGENR:'));
        final String chargeNr = barcodeString.substring(
            barcodeString.indexOf('CHARGENR:') + 9,
            barcodeString.indexOf('\r\nDATE:'));
        final String dateAsString = barcodeString.substring(
            barcodeString.indexOf('DATE:') + 5,
            barcodeString.indexOf('\r\nDOCTOR:'));
        final List<String> c = dateAsString.split('.');
        final String doctorName =
            barcodeString.substring(barcodeString.indexOf('DOCTOR:') + 7);
        final DateTime date = DateTime.utc(int.parse(c.elementAt(2)),
            int.parse(c.elementAt(1)), int.parse(c.elementAt(0)));
        VaccinationDAO.create(vaccineName, chargeNr, date, doctorName, null,
            User.loggedInUser.userDbId, null);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => MyVaccinationPage(
                isFloatingActionButtonVisible: true,
                selectedUser: User.loggedInUser)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 320,
            duration: const Duration(milliseconds: 3000),
            content: Container(
                height: 20,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).vaccineAdded,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        );
      }
    }
  }

  void _calledFromTest(Barcode result) async {
    if (result != null) {
      controller.stopCamera();
      barcodeString = result.code.toString();
      /// url for testing
      // barcodeString = 'https://app.soda-software.de/result/8acb8033ffe2fc52fc9f57f23023965776e03e08dd269f0b';
      if (barcodeString.contains('https://app.soda')) {
        http.Response resp = await http.get(Uri.parse(barcodeString));
        String body = resp.body;

        String testDateString = body.substring(body.indexOf('%M\">') + 4, body.indexOf('</time'));
        DateTime testDate = DateFormat('dd.MM.yyyy hh:mm').parse(testDateString);
        String testName = "";
        Status testStatus = body.contains('NEGATIVE') ? Status.good : body.contains('POSITIVE') ? Status.bad : Status.pending;
        
        List<String> test1 = body.split('\n');
        for (int i = 0; i < test1.length; i++) {
          if (test1[i].contains('Test type')) {
            testName = test1[i + 1].substring(test1[i + 1].indexOf('>') + 1, test1[i + 1].indexOf('</'));
            break;
          }
        }
        if (testName.isNotEmpty) {
          TestDAO.create(testName, null, testDate, testStatus, null, User.loggedInUser.userDbId, null);
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => MyTestPage(
                isFloatingActionButtonVisible: true,
                selectedUser: User.loggedInUser)));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              width: 320,
              duration: const Duration(milliseconds: 3000),
              content: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).testAdded,
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
        );
      }
    }
  }

  void _calledFromFamily(Barcode result) {
    if (result != null) {
      barcodeString = result.code.toString();
      //TODO add family member, check barcode String
      
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => MyFamilyPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 320,
          duration: const Duration(milliseconds: 3000),
          content: Container(
              height: 20,
              child: Center(
                child: Text(
                  AppLocalizations.of(context).familyMemberAdded,
                  textAlign: TextAlign.center,
                ),
              )),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Barcode>('result_qr_scanner', result));
    properties.add(
        DiagnosticsProperty<String>('barcodeString_qr_scanner', barcodeString));
    properties.add(DiagnosticsProperty<QRViewController>(
        'controller_qr_scanner', controller));
    properties.add(DiagnosticsProperty<GlobalKey>('qrKey_qr_scanner', qrKey));
  }
}
