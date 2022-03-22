
import 'package:myapp/objects/music/Song.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Playlist.g.dart';

@JsonSerializable()
class Playlist {
  final String uid;
  final List<Song> songs;
  final String name;
  final String owner;
  final DateTime dateTime; 

  Playlist(this.uid, this.songs, this.name, this.owner, this.dateTime);

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

}