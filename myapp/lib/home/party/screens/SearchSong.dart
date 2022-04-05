import 'package:after_layout/after_layout.dart';
import 'package:myapp/authentication/authManager.dart';

import 'package:myapp/home/HomePage.dart';
import 'package:myapp/home/party/components/SearchBar.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchSong extends ConsumerStatefulWidget {
  static const route = '/searchSong';
  @override
  _SearchSongState createState() => _SearchSongState();
}

class _SearchSongState extends ConsumerState<SearchSong> with AfterLayoutMixin {
  final searchController = TextEditingController();
  final searchBarKey = GlobalKey();
  double searchBarHeight;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() => searchBarHeight = searchBarKey.currentContext.size.height);
  }

  String get query => searchController.text;
  List<Song> filter(List<Song> restaurants) => restaurants
      .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final songs = filter(ref.watch(musicProvider));
    final user = ref.watch(authManagerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          if (searchBarHeight != null)
            songs.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: searchBarHeight + 8)
                        .add(EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(
                      "No results found for: " + query,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: searchBarHeight),
                    itemCount: songs.length,
                    itemBuilder: (context, i) =>
                        SongsTile(songs[i], addSong: true), //Playlist Song Tile
                  ),
          Padding(
            key: searchBarKey,
            padding: EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 8,
            ),
            child: SearchBar(searchController),
          ),
        ],
      ),
    );
  }
}
