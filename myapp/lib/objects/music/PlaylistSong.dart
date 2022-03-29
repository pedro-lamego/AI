import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Song.dart';

part 'PlaylistSong.g.dart';

@JsonSerializable()
class PlaylistSong extends Song {
  String uid;
  final String name;
  final String duration;
  final String srcImage;
  final String artistName;
  final String artistUid;
  final int upvotes;
  final int downvotes;

  PlaylistSong(this.uid, this.name, this.duration, this.srcImage,
      this.artistName, this.artistUid,
      {this.upvotes = 0, this.downvotes = 0})
      : super(uid, name, duration, srcImage, artistName, artistUid);

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistSongToJson(this);
}
