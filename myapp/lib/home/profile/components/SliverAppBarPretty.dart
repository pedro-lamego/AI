import 'package:flutter/material.dart';

class SliverAppBarPretty extends StatelessWidget {
  final String title;
  final Widget child;
  const SliverAppBarPretty(this.title, {this.child, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.backgroundColor,
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(title),
          ),
        ),
        child,
      ],
    );
  }
}
