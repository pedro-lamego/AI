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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 80,
        child: Row(children: [
          Container(
            child: Image.network(song.srcImage),
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  song.artistName,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300,),
                )
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right:15.0),
            child: Icon(Icons.heart_broken),
          ),
        ]),
      ),
    );
  }
}
