// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlaylistUser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistUser _$PlaylistUserFromJson(Map<String, dynamic> json) {
  return PlaylistUser(
    json['uid'] as String,
    (json['songs'] as List)
        ?.map((e) =>
            e == null ? null : PlaylistSong.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['name'] as String,
    json['owner'] as String,
    json['timestamp'] as String,
    json['isOpen'] as bool,
  );
}

Map<String, dynamic> _$PlaylistUserToJson(PlaylistUser instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'songs': instance.songs,
      'name': instance.name,
      'owner': instance.owner,
      'timestamp': instance.timestamp,
      'isOpen': instance.isOpen,
    };
