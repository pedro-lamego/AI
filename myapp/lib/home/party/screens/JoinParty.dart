import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/partyManager.dart';

class JoinParty extends ConsumerWidget {
  static const route = '/joinParty';
  JoinParty({Key key}) : super(key: key);

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
                Text("QrCode Reader"),
                SizedBox(height: 24),
                PressedButton(
                  onPressed: () {
                    ref
                        .read(partyManagerProvider)
                        .joinPartyManager("qMDaBQS1zcc3Mn6a9uzS");
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
