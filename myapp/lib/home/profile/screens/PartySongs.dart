import 'package:flutter/material.dart';
import 'package:myapp/home/profile/components/PlaylistTile.dart';
import 'package:myapp/home/profile/components/SliverAppBarPretty.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/Song.dart';

class PartySongs extends StatelessWidget {
  const PartySongs({Key key}) : super(key: key);
  static String route = '/partySongs';
  @override
  Widget build(BuildContext context) {
    //put stream
    List<Playlist> playlists = [
      Playlist([
        Song("uid1", "song1", "4:20", "art1"),
        Song("uid1", "song2", "4:20", "art2"),
        Song("uid1", "song2", "4:20", "art2")
      ], "name1", "art1", DateTime.now()),
      Playlist([
        Song("uid1", "song1", "4:20", "art1"),
        Song("uid1", "song2", "4:20", "art2"),
        Song("uid1", "song2", "4:20", "art2")
      ], "name2", "art2", DateTime.now()),
      Playlist([
        Song("uid1", "song1", "4:20", "art1"),
        Song("uid1", "song2", "4:20", "art2"),
        Song("uid1", "song2", "4:20", "art2")
      ], "name3", "art3", DateTime.now())
    ];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: theme.backgroundColor,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Parties you\nhave joined"),
              centerTitle: true,
            ),
          ),
          _buildPlaylist(playlists),
        ],
      ),
    );
  }

  Widget _buildPlaylist(List<Playlist> playlists) => SliverToBoxAdapter(
        child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 8),
          itemCount: playlists.length,
          itemBuilder: (context, i) => PlaylistTile(playlists[i], () => {}),
        ),
        // loading: () =>
        //     LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
      );
}
