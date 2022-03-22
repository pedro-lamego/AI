import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/objects/music/Song.dart';

class SongsTile extends ConsumerWidget {
  final Song song;
  SongsTile(this.song);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      child: Row(children: [
        Icon(Icons.accessibility_new_outlined),
        Column(
          children: [Text(song.name), Text(song.artistName)],
        )
      ]),
    );
  }
}
