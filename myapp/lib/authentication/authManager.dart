import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/aspects/failures/authFailure.dart';
import 'package:myapp/aspects/failures/failure.dart';
import 'package:myapp/home/musicManager.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/PlaylistUser.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:myapp/objects/Profile.dart';
import 'package:myapp/services/FileHandler.dart';

final authManagerProvider = Provider<AuthManager>(
  (ref) => AuthManager(ref.read),
);

class AuthManager {
  final Reader _read;
  FirebaseAuth get firebaseAuth => _read(authProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  MusicManager get musicManager => _read(musicManagerProvider);
  PartyManager get partyManager => _read(partyManagerProvider);
  Profile userBloc;

  final _userStream = BehaviorSubject<Profile>();
  Stream<Profile> get profile => _userStream.stream;

  AuthManager(this._read) {
    _loadUserInfo();
  }

  _loadUserInfo() async {
    try {
      if (await FileHandler.fileExists("user.txt")) {
        userBloc = Profile.fromJson(await FileHandler.readFromFile("user.txt"));
        _userStream.add(userBloc);
        await _fetchUserInfo(userBloc.uid);
      } else {
        _userStream.add(null);
      }
    } catch (e) {
      return "error";
    }
  }

  _fetchUserInfo(String userID) async {
    DocumentReference userReference = firestore.collection('users').doc(userID);
    DocumentSnapshot userData = await userReference.get();
    int totalTimeWaiting = 0;
    while (userData.data() == null && totalTimeWaiting < 2000) {
      await Future.delayed(Duration(milliseconds: 100));
      userData = await userReference.get();
      totalTimeWaiting += 100;
    }

    if (userData.data() == null) {
      //TODO couldnt login
      return;
    }

    try {
      dynamic json = userData.data();
      Profile user = Profile.fromJson(json);
      userBloc = user;
    } on Exception catch (_) {
      print("EXCEPTION WTF");
    }
    userBloc.uid = userData.id;
    await saveUser();
    await setUpUserStream();
    await musicManager.setUpMusicStream();
    if (userBloc.playlistToken != "") {
      await partyManager.setUpPartyStream(userBloc.playlistToken);
    }
  }

  _emptyManagers() {
    //todo see if it is necessary
  }

  saveUser() async {
    await FileHandler.writeToFile(userBloc, "user.txt");
    _userStream.add(userBloc);
  }

  deleteUserFile() async {
    userBloc = null;
    await FileHandler.deleteFile("user.txt");
    _userStream.add(userBloc);
  }

  setUpUserStream() async {
    firestore
        .collection("users")
        .doc(userBloc.uid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        userBloc = Profile.fromJson(snapshot.data());
        userBloc.uid = snapshot.id;
        saveUser();
        _userStream.add(userBloc);
      }
    });
  }

  addLikedSong(LikedSong song) {
    Map<String, Map<String, dynamic>> result = {};
    userBloc.likedSongs.addAll({song.uid: song});
    userBloc.likedSongs.forEach((uid, s) {
      result.addAll({
        uid: {
          "uid": uid,
          "name": s.name,
          "duration": s.duration,
          "artistName": s.artistName,
          "artistUid": s.artistUid,
          "srcImage": s.srcImage,
          "timestamp": s.timestamp,
        }
      });
    });

    firestore
        .collection("users")
        .doc(userBloc.uid)
        .update({"likedSongs": result});
  }

  void removeLikedSong(String uid) {
    print("uid");
    Map<String, Map<String, dynamic>> result = {};
    userBloc.likedSongs.remove(uid);
    userBloc.likedSongs.forEach((uid, s) {
      result.addAll({
        uid: {
          "uid": uid,
          "name": s.name,
          "duration": s.duration,
          "artistName": s.artistName,
          "artistUid": s.artistUid,
          "srcImage": s.srcImage,
          "timestamp": s.timestamp,
        }
      });
      firestore
          .collection("users")
          .doc(userBloc.uid)
          .update({"likedSongs": result});
    });
  }

  addPlaylist(Playlist playlist) {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> songs = [];

    playlist.songs.forEach((key, value) {
      songs.add(value.toJson());
    });

    result.addAll({
      "uid": playlist.uid,
      "name": playlist.name,
      "owner": playlist.owner,
      "songs": songs,
      "timestamp": playlist.timestamp,
    });

    print(result);
    firestore.collection("users").doc(userBloc.uid).update({
      "playlists": FieldValue.arrayUnion([result])
    });
  }

  void joinParty(String playlistUid) {
    firestore
        .collection("users")
        .doc(userBloc.uid)
        .update({"playlistToken": playlistUid});
  }

  void kickParty() {
    firestore
        .collection("users")
        .doc(userBloc.uid)
        .update({"playlistToken": ""});
  }

  ///public

  Future<void> registerUserAndPassFirebase(
    BuildContext context, {
    @required String email,
    @required String password,
    @required String name,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userRef =
          firestore.collection('users').doc(userCredential.user.uid).set({
        "name": name,
        "timestamp": DateTime.now().toString(),
        "spotifyToken": "",
        "playlistToken": "",
        "likedSongs": {},
        "playlists": [],
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw AuthFailure.weakPassword(context);
        case 'email-already-in-use':
          throw AuthFailure.emailAlreadyInUse(context);
        default:
          print(e.code);
          throw Failure.unexpected(context);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    Navigator.pop(context);
  }

  Future<void> signInUserAndPassFirebase(
    BuildContext context, {
    @required String email,
    @required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserInfo(userCredential.user.uid);
    } catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw AuthFailure.wrongPassword(context);
        case 'user-not-found':
        case 'invalid-email':
          throw AuthFailure.userNotFound(context);
        case 'too-many-requests':
          throw AuthFailure.tooManyRequests(context);
        default:
          throw Failure.unexpected(context);
      }
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
          throw AuthFailure.userNotFound(context);
        default:
          throw Failure.unexpected(context);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _emptyManagers();
    await firebaseAuth.signOut();
    await deleteUserFile();
  }

  List<Map<String, dynamic>> json = [];

  populateDb() async {
    List<PlaylistSong> list = [];
    for (dynamic album in json) {
      for (dynamic music in album["t"]) {
        Map<String, dynamic> result = {};
        result.addAll({
          "srcImage": album["i"],
          "name": music["n"],
          "duration": music["d"],
          "artistName": album["aN"],
          "artistUid": album["aU"]
        });
        firestore.collection("musics").doc(music["uid"]).set(result);
        // list.add(PlaylistSong(music["uid"], music["n"], music["d"], album["i"],
        //     album["aN"], album["aU"]));
      }
    }
    // addPlaylist(Playlist("uid1", list, "festa da maria", "maria",
    //     DateTime.now().toIso8601String(), true));
  }
}
