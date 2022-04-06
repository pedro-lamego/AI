import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/partyManager.dart';

class JoinParty extends ConsumerStatefulWidget {
  static const route = '/joinParty';
  JoinParty({Key key}) : super(key: key);

  @override
  _JoinPartyState createState() => _JoinPartyState();
}

class _JoinPartyState extends ConsumerState<JoinParty>
    with SingleTickerProviderStateMixin {
  QRViewController controller;
  Barcode result;
  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() async {
    super.reassemble();
    await controller.pauseCamera();
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) print("Result is " + result.code);
    return TapTo.unfocus(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBarPretty(MediaQuery.of(context).size.width),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 120),
                Text(
                  "Join\nParty",
                  maxLines: 2,
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontSize: 36),
                ),
                SizedBox(height: 50),
                Container(
                  width: 300,
                  height: 300,
                  child: buildQrView(context),
                ),
                SizedBox(
                  height: 20,
                ),
                result != null
                    ? PressedButton(
                        onPressed: () {
                          ref
                              .read(partyManagerProvider)
                              .joinPartyManager(result.code);
                          Navigator.pop(
                            context,
                          );
                        },
                        child: Text("JOIN NOW"))
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor, borderRadius: 10),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;

      controller.scannedDataStream.listen((scanData) {
        if (scanData != null && result != scanData) {
          setState(() {
            result = scanData;
          });
        }
      });
    });
  }
}
