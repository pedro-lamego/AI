import 'dart:async';

import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/components/AuthenticationMixin.dart';
import 'package:myapp/authentication/screens/ForgotPassword.dart';
import 'package:myapp/authentication/screens/Register.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const route = '/login';
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with Authentication {
  bool isLoading = false;
  final emailController =
      TextEditingController(text: "pedrownlamego@gmail.com");
  final passwordController = TextEditingController(text: "dengue");

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void forgotPassword() => Navigator.pushNamed(context, ForgotPassword.route);

  void register() => Navigator.pushNamed(context, Register.route);

  bool get fieldsAreEmpty =>
      emailController.text.isEmpty || passwordController.text.isEmpty;

  Future<void> login() async {
    if (fieldsAreEmpty) return;
    return authenticate(
      (authManager) => authManager.signInUserAndPassFirebase(
        context,
        email: emailController.text,
        password: passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapTo.unfocus(
      child: Scaffold(
        body: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context).backgroundColor,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // ignore: prefer_const_constructors
                    Expanded(
                      child: Center(
                        child: Image.asset("assets/images/logo.jpeg", width: 300,),
                      ),
                    ),
                    TextFieldPretty(
                      "Email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFieldPretty(
                      "Password",
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: Text.rich(
                        TextSpan(
                          text: "Forgot your password? ",
                          children: [
                            TextSpan(
                              text: "Click Here",
                              style: TextStyle(
                                color: theme.primaryColor,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = forgotPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    PressedButton(
                      onPressed: login,
                      child: const Text('LOG IN'),
                    ),
                    SizedBox(height: 18),
                    Text.rich(
                      TextSpan(text: "You don't have an account? ", children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = register,
                        ),
                      ]),
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
