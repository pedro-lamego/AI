// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LikedSong.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikedSong _$LikedSongFromJson(Map<String, dynamic> json) {
  return LikedSong(
    json['uid'] as String,
    json['name'] as String,
    json['duration'] as String,
    json['srcImage'] as String,
    json['artistName'] as String,
    json['artistUid'] as String,
    json['timestamp'] as String
  );
}

Map<String, dynamic> _$LikedSongToJson(LikedSong instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'duration': instance.duration,
      'srcImage': instance.srcImage,
      'artistName': instance.artistName,
      'artistUid': instance.artistUid,
      'timestamp': instance.timestamp,
    };
