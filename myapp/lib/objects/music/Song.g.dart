// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) {
  return Song(
    json['uid'] as String,
    json['name'] as String,
    json['duration'] as String,
    json['srcImage'] as String,
    json['artistName'] as String,
    json['artistUid'] as String,
    json['position'] as int,
    json['album'] as String,
  );
}

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'duration': instance.duration,
      'srcImage': instance.srcImage,
      'artistName': instance.artistName,
      'artistUid': instance.artistUid,
      'position': instance.position,
      'album': instance.album,
    };
