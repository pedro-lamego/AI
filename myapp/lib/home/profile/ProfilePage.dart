import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/aspects/widgets/BigPressedButton.dart';
import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartyPlaylists.dart';
import 'package:myapp/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider);
    final theme = Theme.of(context);
    return user.maybeWhen(
      loading: () => LoadingIndicator(indicatorType: Indicator.ballBeat),
      data: (user) => Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 30),
              child: Container(
                child: randomAvatar(user.uid, trBackground: true),
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor, width: 4),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(70),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(user.name,
                  style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w500)),
            ),
            // PressedButton(
            //     onPressed: () => ref.read(authManagerProvider).populateDb(),
            //     child: Text("POPULATE")),
            BigPressedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                LikedSongs.route,
                arguments: user.likedSongs,//TODO see this when i am less high
              ),
              child: const Text("Liked Songs"),
              imgSrc: "disco.jpg",
            ),
            BigPressedButton(
              onPressed: () => Navigator.pushNamed(context, PartyPlaylists.route,
                  arguments: user.playlists),
              child: const Text("Parties you\nhave joined"),
              color: const Color(0xFF7876FF),
              imgSrc: "playlists.jpg",
            ),
          ],
        ),
      ),
    );
  }
}
