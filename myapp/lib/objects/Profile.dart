import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/PlaylistUser.dart';

part 'Profile.g.dart';

@JsonSerializable()
class Profile {
  String uid;
  String name;
  String email;
  String playlistToken;
  String spotifyToken;
  List<PlaylistUser> playlists;
  Map<String, LikedSong> likedSongs;

  Profile(
    this.uid,
    this.name,
    this.email,
    this.playlistToken,
    this.spotifyToken,
    this.likedSongs,
    this.playlists,
  );

  String get profileName => name ?? "You haven't selected your name";

  String get profileEmail => email ?? "You haven't selected you email";

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
