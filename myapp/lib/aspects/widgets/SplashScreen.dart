import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Center(
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                  Color(0xFFE45826),
                  Color(0xFFF0A500),
                  Colors.yellow, //change this color
                ])),
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: const Center(
              child: LoadingIndicator(
                colors: [
                  Color(0xFFE45826),
                ],
                indicatorType: Indicator.ballBeat,
                strokeWidth: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
