import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Song.dart';

part 'PlaylistSong.g.dart';

@JsonSerializable()
class PlaylistSong extends Song {
  List<String> upvotes = [];
  List<String> downvotes = [];
  String timestamp;

  PlaylistSong(uid, name, duration, srcImage, artistName, artistUid,
      this.upvotes, this.downvotes, this.timestamp)
      : super(uid, name, duration, srcImage, artistName, artistUid);

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistSongToJson(this);
  double heuristic() {
    return ((1 * upvotes.length) + (-1.5 * downvotes.length));
  }
}
