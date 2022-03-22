import 'package:flutter/widgets.dart';

class Failure implements Exception {
  final String code;
  final String message;
  const Failure({@required this.code, @required this.message});

  factory Failure.unexpected(BuildContext context) => Failure(
        code: 'unexpected',
        message: "Unexpected error",
      );

  factory Failure.noConection(BuildContext context) => Failure(
        code: 'no-connection',
        message: "No connection",
      );
}
