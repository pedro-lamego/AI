import 'package:myapp/authentication/LoginPage.dart';
import 'package:myapp/authentication/screens/ForgotPassword.dart';
import 'package:myapp/authentication/screens/Register.dart';
import 'package:myapp/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home/party/screens/CreateParty.dart';
import 'package:myapp/home/party/screens/JoinParty.dart';
import 'package:myapp/home/party/screens/SearchSong.dart';
import 'package:myapp/home/party/screens/ShowQRCode.dart';
import 'package:myapp/home/party/screens/SugestedSongs.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartyPlaylists.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';

class RouterConfig {
  static Object _args(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  static Map<String, WidgetBuilder> routes = {
    LoginPage.route: (_) => LoginPage(),
    HomePage.route: (_) => HomePage(),
    Register.route: (_) => Register(),
    ForgotPassword.route: (_) => ForgotPassword(),
    LikedSongs.route: (context) => LikedSongs(),
    PartyPlaylists.route: (context) => PartyPlaylists(),
    PartySongs.route: (context) => PartySongs(_args(context)),
    CreateParty.route: (_) => CreateParty(),
    JoinParty.route: (_) => JoinParty(),
    ShowQRCode.route: (context) => ShowQRCode(_args(context)),
    SugestedSongs.route: (context) => SugestedSongs(_args(context)),
    SearchSong.route: (_) => SearchSong(),
  };
}
