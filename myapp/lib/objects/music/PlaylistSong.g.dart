// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlaylistSong.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistSong _$PlaylistSongFromJson(Map<String, dynamic> json) {
  return PlaylistSong(
    json['uid'],
    json['name'],
    json['duration'],
    json['srcImage'],
    json['artistName'],
    json['artistUid'],
    upvotes: json['upvotes'] as int,
    downvotes: json['downvotes'] as int,
  );
}

Map<String, dynamic> _$PlaylistSongToJson(PlaylistSong instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'duration': instance.duration,
      'srcImage': instance.srcImage,
      'artistName': instance.artistName,
      'artistUid': instance.artistUid,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
    };
