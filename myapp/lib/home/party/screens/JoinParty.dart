import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/screens/QRCodeReader.dart';


class JoinParty extends ConsumerWidget {
  static const route = '/joinParty';
  JoinParty({Key key}) : super(key: key);

  final nameController = TextEditingController();

  String _QRcodeScanned = 'no party found';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text(
                  _QRcodeScanned //this is where the party ID should be
                ),
                SizedBox(height: 50),
                PressedButton(
                  onPressed: () {
                   _awaitQRCodeScannerReturn(context);
                  },
                  child: Text("QrCode Scanner"),
                ),
                SizedBox(height: 24),
                PressedButton(
                  onPressed: () {}
                  // ref
                  // .read(partyManagerProvider)
                  // .joinParty(context, nameController.text),
                  ,
                  child: Text("CONFIRM"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _awaitQRCodeScannerReturn(BuildContext context) async {
    final qRCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeReader()),
    );
    _QRcodeScanned = qRCode;
    print('\n\n############this is the QRcode readed :' + _QRcodeScanned + '################\n\n\ ');
  }
}


