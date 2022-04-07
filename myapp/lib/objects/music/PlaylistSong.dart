import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Song.dart';

part 'PlaylistSong.g.dart';

@JsonSerializable()
class PlaylistSong extends Song {
  List<String> upvotes = [];
  List<String> downvotes = [];
  String timestamp;
  bool alreadyPlayed;
  bool playing;

  PlaylistSong(uid, name, duration, srcImage, artistName, artistUid,position, album,
      this.upvotes, this.downvotes, this.timestamp, this.alreadyPlayed, this.playing)
      : super(uid, name, duration, srcImage, artistName, artistUid, position, album);

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistSongToJson(this);
  double heuristic() {
    return ((1 * upvotes.length) + (-1.5 * downvotes.length));
  }
}
