import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/aspects/widgets/BigPressedButton.dart';
import 'package:myapp/home/profile/screens/LikedSongs.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';
import 'package:myapp/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider);
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
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 4),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(70),
                  ),
                ),
              ),
            ),
            Text(user.name),
            BigPressedButton(
                onPressed: () => Navigator.pushNamed(context, LikedSongs.route,
                    arguments: user.likedSongs),
                child: const Text("Liked Songs")),
            BigPressedButton(
              onPressed: () => Navigator.pushNamed(context, PartySongs.route,
                  arguments: user.playlists),
              child: const Text("Parties you have joined"),
              color: const Color(0xFF7876FF),
            ),
          ],
        ),
      ),
    );
  }
}
