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
    json['position'],
    json['album'],
    (json['upvotes'] as List)?.map((e) => e as String)?.toList(),
    (json['downvotes'] as List)?.map((e) => e as String)?.toList(),
    json['timestamp'] as String,
    json['alreadyPlayed'] as bool,
    json['playing'] as bool,
    
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
      'position': instance.position,
      'album': instance.album,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'timestamp': instance.timestamp,
      'alreadyPlayed': instance.alreadyPlayed,
      'playing': instance.playing,
    };
