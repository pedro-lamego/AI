import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/aspects/widgets/AppBarPretty.dart';
import 'package:myapp/aspects/widgets/SplashScreen.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:riverpod/riverpod.dart';
import 'package:myapp/providers.dart';

class SugestedSongs extends ConsumerWidget {
  static String route = '/sugestedSongs';
  const SugestedSongs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    PartyManager partyManager = ref.read(partyManagerProvider);
    return FutureBuilder(
      future: partyManager.sugestedSongs(),
      initialData: "loading",
      builder: ((context, snapshot) {
        if(snapshot.data == "loading"){
          return SplashScreen();
        }
        print(snapshot.data);
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
              _buildSongs(snapshot.data),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSongs(List<Song> songs) => SliverToBoxAdapter(
    
        child: songs.length == 0
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 220.0),
                  child: Text(
                    "There are no sugested songs,\n check if party has more than 3 songs\n or try it again due to spotify API",
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
