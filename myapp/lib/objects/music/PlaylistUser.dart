import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PlaylistUser.g.dart';

@JsonSerializable()
class PlaylistUser {
  String uid;
  List<PlaylistSong> songs;
  String name;
  String owner;
  String timestamp;
  bool isOpen;

  PlaylistUser(
      this.uid, this.songs, this.name, this.owner, this.timestamp, this.isOpen);

  factory PlaylistUser.fromJson(Map<String, dynamic> json) =>
      _$PlaylistUserFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistUserToJson(this);
}
