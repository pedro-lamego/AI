import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Song.dart';

part 'LikedSong.g.dart';

@JsonSerializable()
class LikedSong extends Song {
  String uid;
  final String name;
  final String duration;
  final String srcImage;
  final String artistName;
  final String artistUid;
  final String timestamp;

  LikedSong(this.uid, this.name, this.duration, this.srcImage, this.artistName,
      this.artistUid, this.timestamp)
      : super(uid, name, duration, srcImage, artistName, artistUid);

  factory LikedSong.fromJson(Map<String, dynamic> json) =>
      _$LikedSongFromJson(json);

  Map<String, dynamic> toJson() => _$LikedSongToJson(this);
}
