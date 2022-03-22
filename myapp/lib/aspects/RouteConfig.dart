import 'package:myapp/authentication/LoginPage.dart';
import 'package:myapp/authentication/screens/ForgotPassword.dart';
import 'package:myapp/authentication/screens/Register.dart';
import 'package:myapp/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home/party/PartyPage.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';

class RouterConfig {
  static Map<String, WidgetBuilder> routes = {
    LoginPage.route: (_) => LoginPage(),
    HomePage.route: (_) => HomePage(),
    Register.route: (_) => Register(),
    ForgotPassword.route: (_) => ForgotPassword(),
    LikedSongs.route: (_) => LikedSongs(),
    PartySongs.route: (_) => PartySongs(),
  };
}
