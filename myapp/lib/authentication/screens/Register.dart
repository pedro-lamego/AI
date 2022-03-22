import 'dart:async';

import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/aspects/widgets/TapTo.dart';
import 'package:myapp/aspects/widgets/TextFieldPretty.dart';
import 'package:myapp/authentication/components/authenticationMixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Register extends ConsumerStatefulWidget {
  static const route = '/register';
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> with Authentication {
  final registerFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get fieldsAreEmpty =>
      nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty;

  bool get isKeyboardOpen => MediaQuery.of(context).viewInsets.bottom != 0;

  Future<void> register() async {
    // if (fieldsAreEmpty) return;
    return authenticate(
      (authManager) => authManager.registerUserAndPassFirebase(
        context,
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      ),
      formKey: registerFormKey,
      ageAndTermsConfirmation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapTo.unfocus(
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBarPretty(MediaQuery.of(context).size.width),
        body: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Center(
                child: Form(
                  key: registerFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: 120),
                      Text(
                        "Create\nAccount",
                        maxLines: 2,
                        style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 36),
                      ),
                      SizedBox(height: 50),
                      TextFieldPretty(
                        "Name",
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      TextFieldPretty(
                        "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      TextFieldPretty(
                        "Password",
                        obscureText: obscurePassword,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      TextFieldPretty(
                        "Confirm Password",
                        obscureText: obscurePassword,
                        controller: confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 24),
                      registerButton
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get registerButton => PressedButton(
        onPressed: register,
        child: Text('REGISTER'),
      );
}
