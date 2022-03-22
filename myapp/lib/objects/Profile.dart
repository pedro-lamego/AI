import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/Song.dart';

part 'Profile.g.dart';

@JsonSerializable()
class Profile {
  String uid;
  String name;
  String email;
  List<Playlist> playlists;
  List<Song> likedSongs;
  
  // @JsonKey(ignore: true) TODO put image in profile
  // File image;

  Profile(this.uid, this.likedSongs, this.playlists, { this.name, this.email,});

  String get profileName => name ?? "You haven't selected your name";

  String get profileEmail => email ?? "You haven't selected you email";

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

}
