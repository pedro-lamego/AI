import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Song.dart';

part 'LikedSong.g.dart';

@JsonSerializable()
class LikedSong extends Song {
  final String timestamp;

  LikedSong(
      uid, name, duration, srcImage, artistName, artistUid, position, album,this.timestamp)
      : super(uid, name, duration, srcImage, artistName, artistUid, position, album);

  factory LikedSong.fromJson(Map<String, dynamic> json) =>
      _$LikedSongFromJson(json);

  Map<String, dynamic> toJson() => _$LikedSongToJson(this);
}
