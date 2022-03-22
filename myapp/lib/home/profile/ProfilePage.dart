import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/home/HomePage.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';
import 'package:myapp/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //stream user
    return Column(children: [
      Icon(Icons.person),
      Text("username"),
      PressedButton(onPressed: () => Navigator.pushNamed(context, LikedSongs.route), child: Text("liked songs")),
      PressedButton(onPressed: () => Navigator.pushNamed(context, PartySongs.route), child: Text("Parties you have joined")),
    ],);
    // body: orders.maybeWhen(
    //   data: (orders) => ListView.builder(
    //     padding: EdgeInsets.only(top: 8),
    //     itemCount: orders.length,
    //     itemBuilder: (context, i) => OrderTile(orders[i]),
    //   ),
    //   loading: () => Loading(),
    //   orElse: () => DataError.unexpected(),
    // ),
  }
}
