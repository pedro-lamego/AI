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
    json['artistName'] as String,
    json['srcImage'] as String,
    json['albumName'] as String,
    upvotes: json['upvotes'] as int,
    downvotes: json['downvotes'] as int,
  );
}

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'duration': instance.duration,
      'artistName': instance.artistName,
      'srcImage': instance.srcImage,
      'albumName': instance.albumName,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
    };
