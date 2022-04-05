// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return Playlist(
    json['uid'] as String,
    (json['songs'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k,
          e == null ? null : PlaylistSong.fromJson(e as Map<String, dynamic>)),
    ),
    json['name'] as String,
    json['owner'] as String,
    json['timestamp'] as String,
    json['isOpen'] as bool,
  );
}

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'uid': instance.uid,
      'songs': instance.songs,
      'name': instance.name,
      'owner': instance.owner,
      'timestamp': instance.timestamp,
      'isOpen': instance.isOpen,
    };
