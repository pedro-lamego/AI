import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFieldPretty extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String hintText;
  final bool obscureText;

  TextFieldPretty(
    this.hintText, {
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText,
  });

  @override
  State<StatefulWidget> createState() => _TextFieldPrettyState();
}

class _TextFieldPrettyState extends State<TextFieldPretty> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText ?? false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Color(0xFFF5F4F2),
          hintText: widget.hintText ?? "",
        ),
      ),
    );
  }
}
