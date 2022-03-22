import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/objects/music/Playlist.dart';

class PlaylistTile extends ConsumerWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  PlaylistTile(this.playlist, this.onTap);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Container(
          child: Text(playlist.name),
          height: 250,
          width: MediaQuery.of(context).size.width * 0.8,
        ), //TODO: go catch images
      ),
    );
  }
}
