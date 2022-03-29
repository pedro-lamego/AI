// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return Playlist(
    json['uid'] as String,
    (json['songs'] as List)
        ?.map((e) =>
            e == null ? null : PlaylistSong.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['name'] as String,
    json['owner'] as String,
    json['dateTime'] == null
        ? null
        : DateTime.parse(json['dateTime'] as String),
  );
}

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'uid': instance.uid,
      'songs': instance.songs,
      'name': instance.name,
      'owner': instance.owner,
      'dateTime': instance.dateTime?.toIso8601String(),
    };
