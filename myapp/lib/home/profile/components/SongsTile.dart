import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';

class SongsTile extends ConsumerStatefulWidget {
  final Song song;
  final bool isLikedSongs;

  SongsTile(this.song, {this.isLikedSongs = true});

  @override
  _SongsTileState createState() => _SongsTileState();
}

class _SongsTileState extends ConsumerState<SongsTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 80,
        child: Row(children: [
          Container(
            child: Image.network(widget.song.srcImage),
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
                  widget.song.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.song.artistName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ),
          Spacer(),
          widget.isLikedSongs //TO DO change this
              ? Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    child: Icon(
                      Icons.star,
                      color: theme.primaryColor,
                    ),
                    onTap: () {
                      ref
                          .read(authManagerProvider)
                          .removeLikedSong(widget.song.uid);
                    },
                    // Icon(
                    //   Icons.star,
                    //   color: theme.backgroundColor,
                    //   border:
                    // ),
                    // onTap: () {
                    //   ref
                    //       .read(authManagerProvider)
                    //       .addLikedSong(widget.song);
                    // },
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
