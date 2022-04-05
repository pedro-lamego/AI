import 'package:flutter/material.dart';
import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/music/Song.dart';

class SugestedSongs extends StatelessWidget {
  final List<Song> songs;

  static String route = '/sugestedSongs';
  const SugestedSongs(this.songs, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                "Sugested Songs",
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

  Widget _buildSongs(List<Song> songs) => SliverToBoxAdapter(
        child: songs.length == 0
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 220.0),
                  child: Text(
                    "There are no sugested songs, check if party has more than 3 songs",
                  ),
                ),
              )
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8),
                itemCount: songs.length,
                itemBuilder: (context, i) => SongsTile(
                  songs[i],
                  addSong: true,
                ),
              ),
      );
}
