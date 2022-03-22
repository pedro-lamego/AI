import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPassword extends ConsumerWidget {
  static const route = '/forgotPassword';
  ForgotPassword({Key key}) : super(key: key);

  final emailController = TextEditingController();

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
                  "Forgot\nPassword",
                  maxLines: 2,
                  style:
                      TextStyle(color: Theme.of(context).hintColor, fontSize: 36),
                ),
                SizedBox(height: 50),
                TextFieldPretty(
                  "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24),
                PressedButton(
                  onPressed: () => ref
                      .read(authManagerProvider)
                      .resetPassword(context, emailController.text),
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
