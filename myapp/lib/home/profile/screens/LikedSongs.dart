import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/home/profile/components/SliverAppBarPretty.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/music/Song.dart';

class LikedSongs extends StatelessWidget {
  final Map<String, Song> likedSongs;
  static String route = '/likedSongs';

  LikedSongs(this.likedSongs, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Song> likedSongsList = [];
    likedSongs.forEach(((_, value) => likedSongsList.add(value)));
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
          _buildPlaylist(likedSongsList),
        ],
      ),
    );
  }

  Widget _buildPlaylist(List<Song> likedSongs) => SliverToBoxAdapter(
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
