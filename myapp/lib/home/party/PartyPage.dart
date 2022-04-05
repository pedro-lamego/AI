import 'package:myapp/aspects/widgets/PressedButton.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/components/Dropdown.dart';
import 'package:myapp/home/party/components/SearchBar.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/home/party/screens/CreateParty.dart';
import 'package:myapp/home/party/screens/JoinParty.dart';
import 'package:myapp/home/profile/components/SongsTile.dart';
import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PartyPage extends ConsumerWidget {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.read(authManagerProvider);
    final user = ref.watch(userStreamProvider);
    final party = ref.watch(partyStreamProvider);
    final partyManager = ref.watch(partyManagerProvider);
    final theme = Theme.of(context);
    return user.maybeWhen(
      data: (user) => user.playlistToken == ""
          ? HomeParty(context, authManager, ref)
          : party.maybeWhen(
              orElse: () => Container(color: Colors.green),
              loading: () => CircularProgressIndicator(),
              data: (party) {
                List<PlaylistSong> songs = [];
                party.songs.forEach((_, value) => songs.add(value));
                songs.sort((a, b) => a.timestamp
                    .compareTo(b.timestamp)); // TODO see if this works
                songs.sort((a, b) => b.heuristic().compareTo(a.heuristic()));
                return SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 6.0),
                      child: Row(
                        children: [
                          Text(party.name,
                              style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600)),
                          Spacer(),
                          Dropdown(user.uid == party.owner)
                        ],
                      ),
                    ),
                    party.songs.length == 0
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 220.0),
                              child: Text(
                                "There are no songs in queue",
                              ),
                            ),
                          )
                        : ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: songs.length,
                            itemBuilder: (context, i) => SongsTile(songs[i],
                                voteSong: true,
                                upvotes: songs[i].upvotes.length,
                                downvotes: songs[i].downvotes.length),
                          ),
                  ]),
                );
              }),
      loading: () => CircularProgressIndicator(),
      orElse: () => Container(
        color: Colors.red,
      ),
    );
  }

  Widget HomeParty(
      BuildContext context, AuthManager authManager, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: PressedButton(
              onPressed: () => Navigator.pushNamed(context, CreateParty.route),
              child: Text(
                "CREATE PARTY",
                style: TextStyle(color: theme.selectedRowColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'or',
              style: TextStyle(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: PressedButton(
              onPressed: () => Navigator.pushNamed(context, JoinParty.route),
              child: Text("JOIN PARTY"),
              color: theme.hintColor,
            ),
          ),
          TextButton(
            onPressed: () => authManager.signOut(context),
            child: Text('Sign out'),
          ),
          Spacer(),
          Image.asset(
            "assets/images/party.jpg",
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }
}
