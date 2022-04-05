// import 'package:mobile_scanner/mobile_scanner.dart';
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
  @override
  Widget build(BuildContext context) {
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
                // MobileScanner(onDetect: (barcode, args) {
                //   final String code = barcode.rawValue;

                //   print(code);
                //   if (code != null)
                //     ref.read(partyManagerProvider).joinPartyManager(code);
                //   Navigator.pop(context);
                // }),
                SizedBox(height: 24),
                PressedButton(
                  onPressed: () {
                    ref
                        .read(partyManagerProvider)
                        .joinPartyManager("xcgAgeWnvX67sg9P2p1y");
                    Navigator.pop(context);
                    return;
                  },
                  child: Text("CONFIRM"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
