import 'package:json_annotation/json_annotation.dart';

part 'Song.g.dart';

@JsonSerializable()
class Song {
  String uid;
  final String name;
  final String duration;
  final String srcImage;
  final String artistName;
  final String artistUid;
  final int position;
  final String album;

  Song(
    this.uid,
    this.name,
    this.duration,
    this.srcImage,
    this.artistName,
    this.artistUid,
    this.position,
    this.album
  );

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}
