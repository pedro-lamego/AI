import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/PlaylistUser.dart';

class PlaylistTile extends ConsumerWidget {
  final PlaylistUser playlist;
  final int index;
  final VoidCallback onTap;
  PlaylistTile(this.playlist, this.index, this.onTap);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // print(playlist.name + " " + playlist.owner );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image:
                        AssetImage("assets/images/party${(index % 4) + 1}.png"),
                    fit: BoxFit.cover)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  playlist.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: theme.selectedRowColor,
                  ),
                ),
              ),
            ),
            height: 130,
            width: MediaQuery.of(context).size.width * 0.8,
          ), //TODO: go catch images
        ),
      ),
    );
  }
}
