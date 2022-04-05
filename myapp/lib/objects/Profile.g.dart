// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['uid'] as String,
    json['name'] as String,
    json['email'] as String,
    json['playlistToken'] as String,
    json['spotifyToken'] as String,
    (json['likedSongs'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : LikedSong.fromJson(e as Map<String, dynamic>)),
    ),
    (json['playlists'] as List)
        ?.map((e) =>
            e == null ? null : PlaylistUser.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'playlistToken': instance.playlistToken,
      'spotifyToken': instance.spotifyToken,
      'playlists': instance.playlists,
      'likedSongs': instance.likedSongs,
    };
