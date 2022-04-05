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
    Map<String, dynamic> songs = {};

    playlist.songs.forEach((key, value) {
      songs.addAll({key : value.toJson()});
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

  List<Map<String, dynamic>> json = [
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273b5b7d7fb1c0de0c070115b76",
      "t": [
        {"n": "Warm (feat. Mia)", "d": "04:15", "uid": "3kBofOTKMUZ62a311eUwvx"}
      ],
      "aN": "Dre'es",
      "aU": "4pc5r183mYvIzGyFv2S0hO"
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
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273347b1bf1afb939a64364a432",
      "t": [
        {"n": "Half-Moon Bag", "d": "05:34", "uid": "0WLw2xoTkQNlbMQxTG7Tyv"},
        {"n": "Toking, Dozing", "d": "04:47", "uid": "76z40sMw3mZJKUL1ODWjSn"},
        {
          "n": "Maybe Another Time",
          "d": "03:05",
          "uid": "6w1Qm9RBUW7mvcuj4YQimE"
        },
        {
          "n": "I'm Warping Here",
          "d": "04:35",
          "uid": "0MPj73CxkssDfy8RUdFN6m"
        },
        {"n": "People Wither", "d": "05:12", "uid": "5giQdpVtrrX8L8mcBNHGIa"},
        {"n": "Day One", "d": "05:21", "uid": "1x5CnN4GQA3WVX63spoXoE"}
      ],
      "aN": "Feng Suave",
      "aU": "73dudJ9j0HStIhJDU8MjMI"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b27360de86e634f2bd4d1364797e",
      "t": [
        {"n": "Come Together", "d": "04:41", "uid": "1l32mo5oW5oIRRjNnVJBNR"},
        {
          "n": "Roll (Burbank Funk)",
          "d": "03:11",
          "uid": "01bfHCsUTwydXCHP1VoLlI"
        },
        {"n": "Come Over", "d": "05:22", "uid": "2hPNuVVSV1tqiD2uPlfehz"},
        {"n": "La Di Da", "d": "03:27", "uid": "5IIq5uEYpUZoSjTEjqn7q1"},
        {"n": "Stay the Night", "d": "04:22", "uid": "0JADBJ42q1ab92VOULBh9V"},
        {"n": "Bravo", "d": "03:26", "uid": "03s6mrEsdLO38EwPOZ6keH"},
        {"n": "Mood", "d": "03:18", "uid": "5biM2vzWFcYOVFcsrYK2wA"},
        {
          "n": "Next Time / Humble Pie",
          "d": "06:41",
          "uid": "18q3Snk21t9JruunyQ9xNT"
        },
        {
          "n": "It Gets Better (With Time)",
          "d": "05:27",
          "uid": "7bKxc7UstlRxOtNBvLjGSs"
        },
        {
          "n": "Look What U Started",
          "d": "05:31",
          "uid": "0sSNa2XDu7dxbnjK0lKnDH"
        },
        {"n": "Wanna Be", "d": "04:27", "uid": "5GjisoOfsN8qagrax01T4y"},
        {"n": "Beat Goes On", "d": "04:16", "uid": "1q1Uk6aQvyjavCsnTb5lFH"},
        {"n": "Hold On", "d": "07:46", "uid": "5tqZJUHEuqdN12RZVq2l9p"}
      ],
      "aN": "The Internet",
      "aU": "7GN9PivdemQRKjDt4z5Zv8"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273cdeeb038a7ed8a85ebd45650",
      "t": [
        {"n": "Us", "d": "03:04", "uid": "5mnh4K9uqRYNpuqd3s1NG0"}
      ],
      "aN": "Miller Blue",
      "aU": "2soHr8jGZ0ATxc6X6BgmbA"
    },
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
      "i": "https://i.scdn.co/image/ab67616d0000b273d755837ea8b6bf0406f44bf7",
      "t": [
        {"n": "Lead", "d": "05:38", "uid": "2UdxBRnSU71nkwtvXxeufm"}
      ],
      "aN": "Safari Zone",
      "aU": "7x2yUTriWOIAWFmmHMdl0w"
    }
  ];

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
