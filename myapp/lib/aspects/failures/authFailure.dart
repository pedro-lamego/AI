import 'package:flutter/widgets.dart';
import 'package:myapp/aspects/failures/failure.dart';

class AuthFailure extends Failure {
  AuthFailure._({
    @required String code,
    @required String message,
  }) : super(code: code, message: message);

  factory AuthFailure.emailAlreadyInUse(BuildContext context) => AuthFailure._(
        code: 'email-already-in-use',
        message: "Email already in use"
      );

  factory AuthFailure.weakPassword(BuildContext context) => AuthFailure._(
        code: 'weak-password',
        message: "Password to weak",
      );

  factory AuthFailure.wrongPassword(BuildContext context) => AuthFailure._(
        code: 'wrong-password',
        message: "Wrong password",
      );

  factory AuthFailure.userNotFound(BuildContext context) => AuthFailure._(
        code: 'user-not-found',
        message: "User not found",
      );

  factory AuthFailure.tooManyRequests(BuildContext context) => AuthFailure._(
        code: 'too-many-requests',
        message: "Too many requests",
      );
}
