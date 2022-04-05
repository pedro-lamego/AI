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

  Song(
    this.uid,
    this.name,
    this.duration,
    this.srcImage,
    this.artistName,
    this.artistUid,
  );

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}
