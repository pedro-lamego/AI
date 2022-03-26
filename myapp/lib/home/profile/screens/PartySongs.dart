import 'package:flutter/material.dart';
import 'package:myapp/home/profile/components/PlaylistTile.dart';
import 'package:myapp/objects/music/Playlist.dart';

class PartySongs extends StatelessWidget {
  List<Playlist> playlists;
  static String route = '/partySongs';

  PartySongs(this.playlists, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //put stream
    // List<Playlist> playlists = [
    //   Playlist(
    //       "uid",
    //       [
    //         Song(
    //           "uid1",
    //           "song1",
    //           "4:20",
    //           "art1",
    //           "name",
    //           "s",
    //         ),
    //         Song(
    //           "uid1",
    //           "song2",
    //           "4:20",
    //           "art2",
    //           "name",
    //           "s",
    //         ),
    //         Song(
    //           "uid1",
    //           "song2",
    //           "4:20",
    //           "art2",
    //           "name",
    //           "s",
    //         )
    //       ],
    //       "name1",
    //       "art1",
    //       DateTime.now()),
    //   Playlist(
    //       "uid2",
    //       [
    //         Song("uid1", "song1", "4:20", "art1", "name", "s"),
    //         Song("uid1", "song2", "4:20", "art2", "name", "s"),
    //         Song("uid1", "song2", "4:20", "art2", "name", "s")
    //       ],
    //       "name2",
    //       "art2",
    //       DateTime.now()),
    //   Playlist(
    //       "uid",
    //       [
    //         Song("uid1", "song1", "4:20", "art1", "name", "s"),
    //         Song("uid1", "song2", "4:20", "art2", "name", "s"),
    //         Song("uid1", "song2", "4:20", "art2", "name", "s"),
    //       ],
    //       "name3",
    //       "art3",
    //       DateTime.now())
    // ];
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
              title: Text("Parties you\nhave joined",
                  style: TextStyle(color: theme.hintColor)),
              centerTitle: true,
            ),
          ),
          _buildPlaylist(playlists),
        ],
      ),
    );
  }

  Widget _buildPlaylist(List<Playlist> playlists) => SliverToBoxAdapter(
        child: playlists.length == 0
            ? const Center(
                child: Padding(
                padding: EdgeInsets.only(top: 200.0),
                child: Text("There are no songs liked"),
              ))
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8),
                itemCount: playlists.length,
                itemBuilder: (context, i) =>
                    PlaylistTile(playlists[i], () => {}),
              ),
        // loading: () =>
        //     LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
      );
}
