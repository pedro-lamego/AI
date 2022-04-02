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
    (json['upvotes'] as List)?.map((e) => e as String)?.toList(),
    (json['downvotes'] as List)?.map((e) => e as String)?.toList(),
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
