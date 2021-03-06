import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Playlist.g.dart';

@JsonSerializable()
class Playlist {
  String uid;
  Map<String, PlaylistSong> songs;
  String name;
  String owner;
  String timestamp;
  bool isOpen;

  String isPlaying = "ready";
  Playlist(
      this.uid, this.songs, this.name, this.owner, this.timestamp, this.isOpen);

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}
