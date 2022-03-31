import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/objects/music/LikedSong.dart';
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
    final user = ref.watch(userStreamProvider);
    return user.maybeWhen(
      data: ((user) => Padding(
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
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
                Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: user.likedSongs.containsKey(widget.song.uid)
                        ? InkWell(
                            child: Icon(
                              Icons.star,
                              color: theme.primaryColor,
                            ),
                            onTap: () {
                              ref
                                  .read(authManagerProvider)
                                  .removeLikedSong(widget.song.uid);
                            },
                          )
                        : InkWell(
                            child: Icon(
                              Icons.star_border,
                              color: theme.primaryColor,
                            ),
                            onTap: () {
                              Song song = widget.song;
                              ref.read(authManagerProvider).addLikedSong(
                                  LikedSong(
                                      song.uid,
                                      song.name,
                                      song.duration,
                                      song.srcImage,
                                      song.artistName,
                                      song.artistUid,
                                      DateTime.now().toIso8601String()));
                            },
                          ))
              ]),
            ),
          )),
    );
  }
}
