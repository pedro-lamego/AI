import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';

class PartyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PressedButton(
            onPressed: () => Navigator.pushNamed(context, LikedSongs.route),
            child: Text("CREATE PARTY")), //TODO Change route
        Text('or'),
        PressedButton(
          onPressed: () => Navigator.pushNamed(context, PartySongs.route),
          child: Text("JOIN PARTY"),
          color: Color(0xFF241C1C),
        ), //TODO
        TextButton(
          onPressed: () => authManager.signOut(context),
          child: Text('Sign out'),
        ),
      ],
    );
  }
}
