import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/profile/components/PlaylistTile.dart';
import 'package:myapp/home/profile/screens/PartySongs.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/providers.dart';

class PartyPlaylists extends ConsumerWidget {
  static String route = '/partyPlaylists';

  PartyPlaylists({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider);
    final theme = Theme.of(context);
    return user.maybeWhen(
      data: (user) => Scaffold(
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
            _buildPlaylist(user.playlists),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist(List<Playlist> playlists) => SliverToBoxAdapter(
        child: playlists.length == 0
            ? const Center(
                child: Padding(
                padding: EdgeInsets.only(top: 200.0),
                child: Text("There are no playlists"),
              ))
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8),
                itemCount: playlists.length,
                itemBuilder: (context, i) =>
                    PlaylistTile(playlists[i], () => Navigator.pushNamed(context, PartySongs.route, arguments: playlists[i].songs)),
              ),
        // loading: () =>
        //     LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
      );
}
