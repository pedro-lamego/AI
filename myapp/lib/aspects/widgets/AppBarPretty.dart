import 'package:flutter/material.dart';

class AppBarPretty extends StatelessWidget implements PreferredSizeWidget {
  final bool implyLeading;
  final double width;

  const AppBarPretty( this.width, {Key key, this.implyLeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      automaticallyImplyLeading: implyLeading ?? true,
      foregroundColor: Theme.of(context).primaryColor,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => Size(width, 50);
}
