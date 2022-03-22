import 'package:json_annotation/json_annotation.dart';

part 'Song.g.dart';

@JsonSerializable()
class Song {
  final String uid;
  final String name;
  final String duration;
  final String artistName;

  Song(this.uid, this.name, this.duration, this.artistName);

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}
