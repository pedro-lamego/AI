import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/aspects/failures/authFailure.dart';
import 'package:myapp/aspects/failures/failure.dart';
import 'package:myapp/objects/music/LikedSong.dart';
import 'package:myapp/objects/music/Playlist.dart';
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
    //TODO change this
    userBloc.playlists.add(playlist);

    firestore.collection("users").doc(userBloc.uid).set(userBloc.toJson());
  }

  removePlaylist(int index) {
    //TODO change this
    userBloc.playlists.removeAt(index);

    firestore.collection("users").doc(userBloc.uid).set(userBloc.toJson());
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

  List<Map<String, dynamic>> json = [
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2732aebf42d8901fbcd14c9eca8",
      "t": [
        {"n": "Before Paris", "d": "02:30", "uid": "4D5POIvEJfBH8wO80Ic4T8"},
        {"n": "Lost in Paris", "d": "03:14", "uid": "4A7DUET5H4f7dJkUhjfVFB"},
        {
          "n": "South of the River",
          "d": "04:30",
          "uid": "5w3yxRRxy5pvZdUvBJF6ve"
        },
        {"n": "Movie", "d": "06:57", "uid": "6pxElwU80zhjbCC77Vn8EI"},
        {"n": "Tick Tock", "d": "04:14", "uid": "3al8a3uZrOZIHc6J1n8i5f"},
        {
          "n": "It Runs Through Me",
          "d": "04:22",
          "uid": "02CygBCQOIyEuhNZqHHcNx"
        },
        {
          "n": "Isn't She Lovely",
          "d": "01:27",
          "uid": "23H8PpuhyTDHwpqcDm7vS6"
        },
        {"n": "Disco Yes", "d": "05:41", "uid": "61Ivix5DTnDPVjp1dgLyov"},
        {"n": "Man Like You", "d": "05:41", "uid": "673BqQR0tNM3VtzcV3Ul2Q"},
        {"n": "Water Baby", "d": "05:32", "uid": "6Pd20wirRDM9k4e69px3dN"},
        {
          "n": "You're On My Mind",
          "d": "04:19",
          "uid": "0ORL2BIQwHdshE8Zp2En2M"
        },
        {"n": "Cos I Love You", "d": "04:14", "uid": "58xN31xmYcfrgA56gAeM3W"},
        {
          "n": "We've Come So Far",
          "d": "04:53",
          "uid": "46mMjdrfaJicOdrOA7NtBa"
        }
      ],
      "aN": "Tom Misch",
      "aU": "1uiEZYehlNivdK3iQyAbye"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2731918c7e10115b80211065022",
      "t": [
        {
          "n": "Honey, There's No Time",
          "d": "04:21",
          "uid": "6utl2puTMct2t0ntNnZc68"
        },
        {"n": "By the Poolside", "d": "04:37", "uid": "0DHRNZ26HFLPnmwDUjGB89"},
        {
          "n": "Sink into the Floor",
          "d": "05:41",
          "uid": "4UCiDcv0yO9tNLZbkZeBBA"
        },
        {"n": "Noche Oscura", "d": "05:46", "uid": "0ZvWdGaWqnPs99z1Xso8YG"}
      ],
      "aN": "Feng Suave",
      "aU": "73dudJ9j0HStIhJDU8MjMI"
    },
  ];

  populateDb() async {
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
        // firestore.collection("musics").doc(music["uid"]).set(result);
        addLikedSong(LikedSong(music["uid"], music["n"], music["d"], album["i"],
            album["aN"], album["aU"], DateTime.now().toIso8601String()));
      }
    }
  }
}
