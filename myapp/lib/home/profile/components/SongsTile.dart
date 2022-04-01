import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';

class SongsTile extends ConsumerStatefulWidget {
  final Song song;
  final bool isLikedSongs;
  final bool addSong;
  final bool voteSong;
  SongsTile(this.song,
      {this.isLikedSongs = true, this.addSong = false, this.voteSong = false});

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
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    child: Image.network(widget.song.srcImage),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width -
                        80 -
                        16 -
                        35 -
                        20 -
                        (widget.addSong ? 40 : 0) -
                        (widget.voteSong ? 80 : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          widget.song.name,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        AutoSizeText(
                          widget.song.artistName,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Spacer(),
                widget.voteSong
                    ? Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: InkWell(
                          child: Icon(
                            Icons.arrow_upward,
                            color: theme.primaryColor,
                          ),
                          onTap: () => ref
                              .read(partyManagerProvider)
                              .upvoteSong(widget.song.uid),
                        ),
                      )
                    : Container(),
                widget.voteSong
                    ? Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: InkWell(
                          child: Icon(
                            Icons.arrow_downward,
                            color: theme.primaryColor,
                          ),
                          onTap: () => ref
                              .read(partyManagerProvider)
                              .downvoteSong(widget.song.uid),
                        ),
                      )
                    : Container(),
                widget.addSong
                    ? Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: InkWell(
                          child: Icon(
                            Icons.add,
                            color: theme.primaryColor,
                          ),
                          onTap: () => ref
                              .read(partyManagerProvider)
                              .addSongToParty(widget.song),
                        ),
                      )
                    : Container(),
                Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: user.likedSongs.containsKey(widget.song.uid)
                        ? InkWell(
                            child: Icon(
                              Icons.star,
                              color: theme.primaryColor,
                            ),
                            onTap: () => ref
                                .read(authManagerProvider)
                                .removeLikedSong(widget.song.uid),
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
