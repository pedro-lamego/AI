// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['uid'] as String,
    (json['likedSongs'] as List)
        ?.map(
            (e) => e == null ? null : Song.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['playlists'] as List)
        ?.map((e) =>
            e == null ? null : Playlist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'playlists': instance.playlists,
      'likedSongs': instance.likedSongs,
    };
