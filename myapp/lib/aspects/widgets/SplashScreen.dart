import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
          child: Container(
            width: 50,
            child: LoadingIndicator(
        colors: [
            theme.primaryColor,
        ],
        indicatorType: Indicator.ballBeat,
        strokeWidth: 20,
      ),
          )),
    );
  }
}
