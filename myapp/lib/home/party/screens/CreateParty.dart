import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateParty extends ConsumerWidget {
  static const route = '/createParty';
  CreateParty({Key key}) : super(key: key);

  final nameController = TextEditingController();

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
                  "Create\nParty",
                  maxLines: 2,
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontSize: 36),
                ),
                SizedBox(height: 50),
                TextFieldPretty(
                  "Name",
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24),
                PressedButton(
                  onPressed: () {}
                  // ref
                  // .read(partyManagerProvider)
                  // .createParty(context, nameController.text),
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
}
