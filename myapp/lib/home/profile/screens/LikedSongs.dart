import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/profile/components/SliverAppBarPretty.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/Profile.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';

class LikedSongs extends ConsumerWidget {
  static String route = '/likedSongs';

  LikedSongs({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider);
    final theme = Theme.of(context);
    List<LikedSong> likedSongsList = [];
    return user.maybeWhen(data: (user) {
      user.likedSongs.forEach(((_, value) => likedSongsList.add(value)));
      likedSongsList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: theme.primaryColor,
              backgroundColor: theme.backgroundColor,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Liked Songs",
                  style: TextStyle(color: theme.hintColor),
                ),
                centerTitle: true,
              ),
            ),
            _buildSongs(likedSongsList),
          ],
        ),
      );
    });
  }

  Widget _buildSongs(List<Song> likedSongs) => SliverToBoxAdapter(
        child: likedSongs.length == 0
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 220.0),
                  child: Text(
                    "There are no songs liked",
                  ),
                ),
              )
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8),
                itemCount: likedSongs.length,
                itemBuilder: (context, i) => SongsTile(likedSongs[i]),
              ),
        // loading: () =>
        //     LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
      );
}
