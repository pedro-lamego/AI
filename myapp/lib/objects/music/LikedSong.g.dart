// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LikedSong.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikedSong _$LikedSongFromJson(Map<String, dynamic> json) {
  return LikedSong(
    json['uid'],
    json['name'],
    json['duration'],
    json['srcImage'],
    json['artistName'],
    json['artistUid'],
    json['timestamp'] as String,
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
