import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    await getDevices();
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
          "position": s.position,
          "album": s.album,
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
          "position": s.position,
          "album": s.album,
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

  List<Map<String, dynamic>> json = [
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273a2292e6015805f1224928dc6",
      "t": [
        {
          "n": "Intro",
          "d": "02:48",
          "uid": "spotify:track:70wHECbwn2g3yPa2oirqn0",
          "pos": 1
        },
        {
          "n": "At the Bar",
          "d": "03:30",
          "uid": "spotify:track:2C67OHbZjiG90ojqFn63HW",
          "pos": 2
        },
        {
          "n": "Diggin'",
          "d": "04:21",
          "uid": "spotify:track:1IJSvKkI2bhttdFjcnPHne",
          "pos": 3
        },
        {
          "n": "Calcata",
          "d": "04:32",
          "uid": "spotify:track:5b2xh0sIWQRsL22Pl25mxT",
          "pos": 4
        },
        {
          "n": "Godot",
          "d": "08:58",
          "uid": "spotify:track:52EU1aAI9DVkmbLa00nZUl",
          "pos": 5
        }
      ],
      "aN": "Quiver",
      "aU": "5Sce1bRzY2D0fD13dJX7yO",
      "uri": "spotify:album:72IwMNE0EYNv82Pq20MEsS"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2737781786637940540efa4492b",
      "t": [
        {
          "n": "Chronic Sunshine",
          "d": "05:31",
          "uid": "spotify:track:2RGe02P8xxSF9syj0ltPjX",
          "pos": 1
        }
      ],
      "aN": "Cosmo Pyke",
      "aU": "1RKG6WXRzmTJtbLRZTPU0T",
      "uri": "spotify:album:2GVSTqYcLPfhtpkE7mTR99"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273617c314e94693fad9a26f798",
      "t": [
        {
          "n": "Get You (feat. Kali Uchis)",
          "d": "05:37",
          "uid": "spotify:track:6N3qHjcwly8ZuhE4bPYJAX",
          "pos": 1
        },
        {
          "n": "Japanese Denim",
          "d": "05:31",
          "uid": "spotify:track:1boXOL0ua7N2iCOUVI1p9F",
          "pos": 2
        }
      ],
      "aN": "Daniel Caesar",
      "aU": "20wkVLutqVOYrc0kxFs7rA",
      "uri": "spotify:album:5qfhZ5YkZ4LhEUbYgjrWt6"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273965f1a626c0d8667af96d7d3",
      "t": [
        {
          "n": "Sound & Color",
          "d": "03:02",
          "uid": "spotify:track:4jVQBszyxsa0GeRSe5ToVC",
          "pos": 1
        },
        {
          "n": "Don't Wanna Fight",
          "d": "04:53",
          "uid": "spotify:track:51LcPhaclbiR8EAyC76M2L",
          "pos": 2
        },
        {
          "n": "Dunes",
          "d": "04:18",
          "uid": "spotify:track:1FIopLuSI1am9L8Qfn6YRR",
          "pos": 3
        },
        {
          "n": "Future People",
          "d": "03:22",
          "uid": "spotify:track:6CFJ419mkYr35Vs5D75LzV",
          "pos": 4
        },
        {
          "n": "Gimme All Your Love",
          "d": "04:03",
          "uid": "spotify:track:3DH42U4bDllHWK6tQc4OQF",
          "pos": 5
        },
        {
          "n": "This Feeling",
          "d": "04:29",
          "uid": "spotify:track:2zhfCGN6y15c4ArUHXi9g7",
          "pos": 6
        },
        {
          "n": "Guess Who",
          "d": "03:16",
          "uid": "spotify:track:44eHr3F6XhEee5znQ05yrM",
          "pos": 7
        },
        {
          "n": "The Greatest",
          "d": "04:50",
          "uid": "spotify:track:0EyKezohJwSdqyMzXWsqND",
          "pos": 8
        },
        {
          "n": "Shoegaze",
          "d": "03:59",
          "uid": "spotify:track:3gUXn562icG8RVd8JMwH22",
          "pos": 9
        },
        {
          "n": "Miss You",
          "d": "04:47",
          "uid": "spotify:track:72sYnczWVDAWqYoJSvgsCx",
          "pos": 10
        },
        {
          "n": "Gemini",
          "d": "07:36",
          "uid": "spotify:track:3oM0gt7y574aPlLERyaNja",
          "pos": 11
        },
        {
          "n": "Over My Head",
          "d": "04:51",
          "uid": "spotify:track:02iH3pu6r76OzE8OXIu69r",
          "pos": 12
        }
      ],
      "aN": "Alabama Shakes",
      "aU": "16GcWuvvybAoaHr0NqT8Eh",
      "uri": "spotify:album:03nQNGFi3dIxg6ghNbtVWW"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b27338b1c0864dac8e7f05401302",
      "t": [
        {
          "n": "It's Been a Long Time",
          "d": "03:59",
          "uid": "spotify:track:3hfeTkSTd3ruEyoBQkBdUb",
          "pos": 1
        },
        {
          "n": "Do It Again",
          "d": "04:59",
          "uid": "spotify:track:7cjbglDR6yec0j1gl92ApG",
          "pos": 2
        },
        {
          "n": "Smiling",
          "d": "03:20",
          "uid": "spotify:track:3WM1tXhp9IXRFP6pXC2AEc",
          "pos": 3
        },
        {
          "n": "Guilty",
          "d": "04:35",
          "uid": "spotify:track:5ICdHl6m8XMMZbvAR3fylo",
          "pos": 4
        },
        {
          "n": "In Love (Don't Mess Things Up)",
          "d": "02:17",
          "uid": "spotify:track:0ATTj6ecm8A8RiT7mz9GK6",
          "pos": 5
        },
        {
          "n": "Make Me Over",
          "d": "02:25",
          "uid": "spotify:track:5XQTEcBg8xWocyEdYhMsYZ",
          "pos": 6
        },
        {
          "n": "Cut Me Loose",
          "d": "03:28",
          "uid": "spotify:track:1fF2EPtqRmO5FRZ6AWYw0C",
          "pos": 7
        },
        {
          "n": "Underneath My Feet",
          "d": "03:40",
          "uid": "spotify:track:3d2NhOJtj7aTzipQ3mr4Aq",
          "pos": 8
        },
        {
          "n": "They Won't Hang Around",
          "d": "04:54",
          "uid": "spotify:track:5LyYj4so3xijy4AjOhgWEB",
          "pos": 9
        },
        {
          "n": "Bad Girl",
          "d": "03:44",
          "uid": "spotify:track:1sei51TK8wdPNc8tmwsrSc",
          "pos": 10
        },
        {
          "n": "Let It Go",
          "d": "04:40",
          "uid": "spotify:track:22FrNStyxnmALOpBJFXWyk",
          "pos": 11
        }
      ],
      "aN": "Lady Wray",
      "aU": "1plioVQ0mcgAO7uhvWkJJy",
      "uri": "spotify:album:4iJH23rAmDOdapyI9DFRd8"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273ce1455251bfb5e0245c77bc8",
      "t": [
        {
          "n": "Another Lifetime",
          "d": "03:29",
          "uid": "spotify:track:48WTGGIeSFD5ZMF51Rm4Y9",
          "pos": 1
        },
        {
          "n": "Make It Out Alive (feat. SiR)",
          "d": "04:59",
          "uid": "spotify:track:0VXinRGqxFxr1BKrOrC9pP",
          "pos": 2
        },
        {
          "n": "If You Ever",
          "d": "04:40",
          "uid": "spotify:track:5qbSSuBorHMw2wXC3qPe2Z",
          "pos": 3
        },
        {
          "n": "When Saturn Returns - Interlude",
          "d": "01:59",
          "uid": "spotify:track:7F23U974sp3gkkCTA4gJ4M",
          "pos": 4
        },
        {
          "n": "Saturn (feat. Kwabs)",
          "d": "05:50",
          "uid": "spotify:track:7HHlagS4aGF82LduE2FoY4",
          "pos": 5
        },
        {
          "n": "Gabriel",
          "d": "04:51",
          "uid": "spotify:track:5fp8Ww74MLFXjCYRxf6YMt",
          "pos": 6
        },
        {
          "n": "Orbit",
          "d": "04:54",
          "uid": "spotify:track:5yrXolC7Un3peiFxwqbucn",
          "pos": 7
        },
        {
          "n": "Love Supreme",
          "d": "04:16",
          "uid": "spotify:track:591qGFsTHMPHQ9V6lz4CKJ",
          "pos": 8
        },
        {
          "n": "Curiosity",
          "d": "04:36",
          "uid": "spotify:track:6j1owOuV2iTquW5vTw1fm3",
          "pos": 9
        },
        {
          "n": "Drive and Disconnect",
          "d": "04:30",
          "uid": "spotify:track:6pEAd0UjznaKABT7WLLvmC",
          "pos": 10
        },
        {
          "n": "Don't Change",
          "d": "03:28",
          "uid": "spotify:track:3tyB3Y7sfc02VwtsnW3aCO",
          "pos": 11
        },
        {
          "n": "Yellow of the Sun",
          "d": "04:51",
          "uid": "spotify:track:1sopAWv0BToiOT2wAunyuV",
          "pos": 12
        },
        {
          "n": "A Life Like This",
          "d": "04:38",
          "uid": "spotify:track:7c8bCcNTQTx13FkjtKkb8E",
          "pos": 13
        }
      ],
      "aN": "Nao",
      "aU": "7aFTOGFDEqDtJUCziLVsVC",
      "uri": "spotify:album:5rojZ5uUIKKkfNsFT92Vld"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273b738999a454f126cb39b3b1c",
      "t": [
        {
          "n": "Night Walk",
          "d": "04:18",
          "uid": "spotify:track:3CKXSzkxqgNMrM5YTR1qKB",
          "pos": 1
        }
      ],
      "aN": "Gold Fir",
      "aU": "4dyk18v6VAa3Yb593eqmcE",
      "uri": "spotify:album:5mhECCl98nmq9BMFdFCWLi"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273bf818d032f92466cd2ab9e2c",
      "t": [
        {
          "n": "Too Fast",
          "d": "04:35",
          "uid": "spotify:track:0gqG3JmjuP4Pk8rIMwRCUJ",
          "pos": 1
        }
      ],
      "aN": "Yeek",
      "aU": "5BhFZpE8kUGZJiKOsYjLQM",
      "uri": "spotify:album:5q1WO4a40Kvfo8J66Lagsh"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2732aebf42d8901fbcd14c9eca8",
      "t": [
        {
          "n": "Before Paris",
          "d": "02:30",
          "uid": "spotify:track:4D5POIvEJfBH8wO80Ic4T8",
          "pos": 1
        },
        {
          "n": "Lost in Paris",
          "d": "03:14",
          "uid": "spotify:track:4A7DUET5H4f7dJkUhjfVFB",
          "pos": 2
        },
        {
          "n": "South of the River",
          "d": "04:30",
          "uid": "spotify:track:5w3yxRRxy5pvZdUvBJF6ve",
          "pos": 3
        },
        {
          "n": "Movie",
          "d": "06:57",
          "uid": "spotify:track:6pxElwU80zhjbCC77Vn8EI",
          "pos": 4
        },
        {
          "n": "Tick Tock",
          "d": "04:14",
          "uid": "spotify:track:3al8a3uZrOZIHc6J1n8i5f",
          "pos": 5
        },
        {
          "n": "It Runs Through Me",
          "d": "04:22",
          "uid": "spotify:track:02CygBCQOIyEuhNZqHHcNx",
          "pos": 6
        },
        {
          "n": "Isn't She Lovely",
          "d": "01:27",
          "uid": "spotify:track:23H8PpuhyTDHwpqcDm7vS6",
          "pos": 7
        },
        {
          "n": "Disco Yes",
          "d": "05:41",
          "uid": "spotify:track:61Ivix5DTnDPVjp1dgLyov",
          "pos": 8
        },
        {
          "n": "Man Like You",
          "d": "05:41",
          "uid": "spotify:track:673BqQR0tNM3VtzcV3Ul2Q",
          "pos": 9
        },
        {
          "n": "Water Baby",
          "d": "05:32",
          "uid": "spotify:track:6Pd20wirRDM9k4e69px3dN",
          "pos": 10
        },
        {
          "n": "You're On My Mind",
          "d": "04:19",
          "uid": "spotify:track:0ORL2BIQwHdshE8Zp2En2M",
          "pos": 11
        },
        {
          "n": "Cos I Love You",
          "d": "04:14",
          "uid": "spotify:track:58xN31xmYcfrgA56gAeM3W",
          "pos": 12
        },
        {
          "n": "We've Come So Far",
          "d": "04:53",
          "uid": "spotify:track:46mMjdrfaJicOdrOA7NtBa",
          "pos": 13
        }
      ],
      "aN": "Tom Misch",
      "aU": "1uiEZYehlNivdK3iQyAbye",
      "uri": "spotify:album:28enuddLPEA914scE6Drvk"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273a55f73b70360daa13f3f30c2",
      "t": [
        {
          "n": "Wish You Were Gone",
          "d": "04:21",
          "uid": "spotify:track:3PTW5X4BlDqVkxNoTTqBqb",
          "pos": 1
        },
        {
          "n": "Chronic Sunshine",
          "d": "05:31",
          "uid": "spotify:track:3pnGJPnBptOIEa4bvdcLlG",
          "pos": 2
        },
        {
          "n": "After School Club",
          "d": "05:15",
          "uid": "spotify:track:7BpBtD7M2gVdAnKBkhSWPc",
          "pos": 3
        },
        {
          "n": "Social Sites",
          "d": "05:49",
          "uid": "spotify:track:4jE1fmY1evwHShz81sCZlv",
          "pos": 4
        },
        {
          "n": "Great Dane",
          "d": "08:58",
          "uid": "spotify:track:6OCFXXVmoPFtidXA7ey1SI",
          "pos": 5
        }
      ],
      "aN": "Cosmo Pyke",
      "aU": "1RKG6WXRzmTJtbLRZTPU0T",
      "uri": "spotify:album:7tp5vLtNVMJEmoPbJEA1e0"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2734102c5c0e3ec0b9ea6eeeb35",
      "t": [
        {
          "n": "Intro~",
          "d": "03:33",
          "uid": "spotify:track:6tONDRvH1PwW5B7YjCLCHB",
          "pos": 1
        },
        {
          "n": "~Outro",
          "d": "02:23",
          "uid": "spotify:track:4tH7qusSwqxCjx4c4tphtE",
          "pos": 2
        },
        {
          "n": "Stranger",
          "d": "04:38",
          "uid": "spotify:track:4MQwH8UtOM4qgJxd16kJX5",
          "pos": 3
        },
        {
          "n": "Some Feeling",
          "d": "03:17",
          "uid": "spotify:track:5e0b8UxDpZQro2cUCtK29Q",
          "pos": 4
        },
        {
          "n": "Mysight",
          "d": "04:19",
          "uid": "spotify:track:3y54TlZtGwtHapnvGEnwGX",
          "pos": 5
        },
        {
          "n": "Down By The River",
          "d": "04:57",
          "uid": "spotify:track:50jPA11pFqdxB1wMK9Fz9h",
          "pos": 6
        },
        {
          "n": "Selfish Lover",
          "d": "05:45",
          "uid": "spotify:track:7gWvM2Ffp63wX3NlcssJ9N",
          "pos": 7
        },
        {
          "n": "Losing Time",
          "d": "05:41",
          "uid": "spotify:track:6qfLL2ZoxIpqfzxrqXqEjP",
          "pos": 8
        },
        {
          "n": "In The Living Room",
          "d": "04:52",
          "uid": "spotify:track:6eXUUOfhAh6m7Udp53NE0W",
          "pos": 9
        },
        {
          "n": "Where Are We Now?",
          "d": "05:52",
          "uid": "spotify:track:5eYPrjCCB5qejaeArNGfpI",
          "pos": 10
        },
        {
          "n": "Terandara",
          "d": "03:27",
          "uid": "spotify:track:3Gdg0B64ZBIu1KIUM7JPzS",
          "pos": 11
        }
      ],
      "aN": "Mild Orange",
      "aU": "6yXBFHhojjdwKoop55NsHf",
      "uri": "spotify:album:63owNfr6ha16jnJWWIvh6z"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2734a42166d927b3acce345c5c0",
      "t": [
        {
          "n": "3 Nights",
          "d": "03:58",
          "uid": "spotify:track:1tNJrcVe6gwLEiZCtprs1u",
          "pos": 1
        },
        {
          "n": "She Wants My Money",
          "d": "02:14",
          "uid": "spotify:track:2VMJkgrhqfOOYBlZif2nvX",
          "pos": 2
        },
        {
          "n": "Babydoll",
          "d": "02:38",
          "uid": "spotify:track:1SocftHhtuqF7k83eUhHiz",
          "pos": 3
        },
        {
          "n": "Westcoast Collective",
          "d": "02:47",
          "uid": "spotify:track:582ndoUAn4YIN30NUnK6S2",
          "pos": 4
        },
        {
          "n": "Socks",
          "d": "02:11",
          "uid": "spotify:track:32KU85vllRfxfaV7ZNvHwT",
          "pos": 5
        },
        {
          "n": "King of Everything",
          "d": "03:14",
          "uid": "spotify:track:5IWW129DwGyMVQAbaJz3rS",
          "pos": 6
        }
      ],
      "aN": "Dominic Fike",
      "aU": "6USv9qhCn6zfxlBQIYJ9qs",
      "uri": "spotify:album:1DNx0H5ZX1ax3yyRwtgT4S"
    },
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
          "artistUid": album["aU"],
          "album" : album["uri"],
          "position" : music["pos"]
        });
        firestore.collection("musics").doc(music["uid"]).set(result);
        // list.add(PlaylistSong(music["uid"], music["n"], music["d"], album["i"],
        //     album["aN"], album["aU"]));
      }
    }
    // addPlaylist(Playlist("uid1", list, "festa da maria", "maria",
    //     DateTime.now().toIso8601String(), true));
  }

  getDevices() async {
    HttpsCallableResult result =
        await FirebaseFunctions.instance.httpsCallable("getDevices").call();
    print(result);
  }
}
