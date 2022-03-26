import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/screens/CreateParty.dart';
import 'package:myapp/home/party/screens/JoinParty.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';

class PartyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: PressedButton(
              onPressed: () => Navigator.pushNamed(context, CreateParty.route),
              child: Text(
                "CREATE PARTY",
                style: TextStyle(color: theme.selectedRowColor),
              ),
            ),
          ), 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'or',
              style: TextStyle(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: PressedButton(
              onPressed: () => Navigator.pushNamed(context, JoinParty.route),
              child: Text("JOIN PARTY"),
              color: theme.hintColor,
            ),
          ), 
          // TextButton(
          //   onPressed: () => authManager.signOut(context),
          //   child: Text('Sign out'),
          // ),
          Spacer(),
          Image.asset("assets/images/party.jpg", alignment: Alignment.bottomCenter,)
        ],
      ),
    );
  }
}
