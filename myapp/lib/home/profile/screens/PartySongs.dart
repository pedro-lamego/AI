import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/profile/components/SliverAppBarPretty.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/Profile.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';

class PartySongs extends ConsumerWidget {
  static String route = '/partySongs';
  final List<PlaylistSong> songs;
  PartySongs(this.songs, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                  "Party Songs",
                  style: TextStyle(color: theme.hintColor),
                ),
                centerTitle: true,
              ),
            ),
            _buildSongs(songs),
          ],
        ),
      );
  }

  Widget _buildSongs(List<Song> partySongs) => SliverToBoxAdapter(
        child: partySongs.length == 0
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
                itemCount: partySongs.length,
                itemBuilder: (context, i) => SongsTile(partySongs[i], isLikedSongs: false),
              ),
        // loading: () =>
        //     LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
      );
}
