import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';

import 'package:myapp/objects/music/PlaylistSong.dart';

class BottomMusicPlayerBar extends StatefulWidget {
  PlaylistSong song;
  bool isAdmin;
  BottomMusicPlayerBar(this.song, this.isAdmin);
  @override
  State<StatefulWidget> createState() => _BottomMusicPlayerBarState();
}

class _BottomMusicPlayerBarState extends State<BottomMusicPlayerBar> {
  static const double _playerMinHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    return Miniplayer(
      minHeight: _playerMinHeight,
      maxHeight: MediaQuery.of(context).size.height,
      builder: (height, percentage) {
        return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Image.network(
                  widget.song.srcImage,
                  height: _playerMinHeight - 4.0,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            widget.song.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Flexible(
                            child: Text(
                          widget.song.artistName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ))
                      ],
                    ),
                  ),
                ),
                widget.isAdmin
                    ? IconButton(onPressed: () {}, icon: Icon(Icons.stop))
                    : Spacer(),
                widget.isAdmin
                    ? IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.keyboard_double_arrow_right))
                    : Spacer(),
              ],
            ));
      },
    );
  }
}
