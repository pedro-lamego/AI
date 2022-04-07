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

  List<Map<String, dynamic>> json = [
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273a2292e6015805f1224928dc6",
      "t": [
        {
          "n": "Intro",
          "d": "02:48",
          "uid": "spotify:track:70wHECbwn2g3yPa2oirqn0"
        },
        {
          "n": "At the Bar",
          "d": "03:30",
          "uid": "spotify:track:2C67OHbZjiG90ojqFn63HW"
        },
        {
          "n": "Diggin'",
          "d": "04:21",
          "uid": "spotify:track:1IJSvKkI2bhttdFjcnPHne"
        },
        {
          "n": "Calcata",
          "d": "04:32",
          "uid": "spotify:track:5b2xh0sIWQRsL22Pl25mxT"
        },
        {
          "n": "Godot",
          "d": "08:58",
          "uid": "spotify:track:52EU1aAI9DVkmbLa00nZUl"
        }
      ],
      "aN": "Quiver",
      "aU": "5Sce1bRzY2D0fD13dJX7yO"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2737781786637940540efa4492b",
      "t": [
        {
          "n": "Chronic Sunshine",
          "d": "05:31",
          "uid": "spotify:track:2RGe02P8xxSF9syj0ltPjX"
        }
      ],
      "aN": "Cosmo Pyke",
      "aU": "1RKG6WXRzmTJtbLRZTPU0T"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273617c314e94693fad9a26f798",
      "t": [
        {
          "n": "Get You (feat. Kali Uchis)",
          "d": "05:37",
          "uid": "spotify:track:6N3qHjcwly8ZuhE4bPYJAX"
        },
        {
          "n": "Japanese Denim",
          "d": "05:31",
          "uid": "spotify:track:1boXOL0ua7N2iCOUVI1p9F"
        }
      ],
      "aN": "Daniel Caesar",
      "aU": "20wkVLutqVOYrc0kxFs7rA"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273965f1a626c0d8667af96d7d3",
      "t": [
        {
          "n": "Sound & Color",
          "d": "03:02",
          "uid": "spotify:track:4jVQBszyxsa0GeRSe5ToVC"
        },
        {
          "n": "Don't Wanna Fight",
          "d": "04:53",
          "uid": "spotify:track:51LcPhaclbiR8EAyC76M2L"
        },
        {
          "n": "Dunes",
          "d": "04:18",
          "uid": "spotify:track:1FIopLuSI1am9L8Qfn6YRR"
        },
        {
          "n": "Future People",
          "d": "03:22",
          "uid": "spotify:track:6CFJ419mkYr35Vs5D75LzV"
        },
        {
          "n": "Gimme All Your Love",
          "d": "04:03",
          "uid": "spotify:track:3DH42U4bDllHWK6tQc4OQF"
        },
        {
          "n": "This Feeling",
          "d": "04:29",
          "uid": "spotify:track:2zhfCGN6y15c4ArUHXi9g7"
        },
        {
          "n": "Guess Who",
          "d": "03:16",
          "uid": "spotify:track:44eHr3F6XhEee5znQ05yrM"
        },
        {
          "n": "The Greatest",
          "d": "04:50",
          "uid": "spotify:track:0EyKezohJwSdqyMzXWsqND"
        },
        {
          "n": "Shoegaze",
          "d": "03:59",
          "uid": "spotify:track:3gUXn562icG8RVd8JMwH22"
        },
        {
          "n": "Miss You",
          "d": "04:47",
          "uid": "spotify:track:72sYnczWVDAWqYoJSvgsCx"
        },
        {
          "n": "Gemini",
          "d": "07:36",
          "uid": "spotify:track:3oM0gt7y574aPlLERyaNja"
        },
        {
          "n": "Over My Head",
          "d": "04:51",
          "uid": "spotify:track:02iH3pu6r76OzE8OXIu69r"
        }
      ],
      "aN": "Alabama Shakes",
      "aU": "16GcWuvvybAoaHr0NqT8Eh"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b27338b1c0864dac8e7f05401302",
      "t": [
        {
          "n": "It's Been a Long Time",
          "d": "03:59",
          "uid": "spotify:track:3hfeTkSTd3ruEyoBQkBdUb"
        },
        {
          "n": "Do It Again",
          "d": "04:59",
          "uid": "spotify:track:7cjbglDR6yec0j1gl92ApG"
        },
        {
          "n": "Smiling",
          "d": "03:20",
          "uid": "spotify:track:3WM1tXhp9IXRFP6pXC2AEc"
        },
        {
          "n": "Guilty",
          "d": "04:35",
          "uid": "spotify:track:5ICdHl6m8XMMZbvAR3fylo"
        },
        {
          "n": "In Love (Don't Mess Things Up)",
          "d": "02:17",
          "uid": "spotify:track:0ATTj6ecm8A8RiT7mz9GK6"
        },
        {
          "n": "Make Me Over",
          "d": "02:25",
          "uid": "spotify:track:5XQTEcBg8xWocyEdYhMsYZ"
        },
        {
          "n": "Cut Me Loose",
          "d": "03:28",
          "uid": "spotify:track:1fF2EPtqRmO5FRZ6AWYw0C"
        },
        {
          "n": "Underneath My Feet",
          "d": "03:40",
          "uid": "spotify:track:3d2NhOJtj7aTzipQ3mr4Aq"
        },
        {
          "n": "They Won't Hang Around",
          "d": "04:54",
          "uid": "spotify:track:5LyYj4so3xijy4AjOhgWEB"
        },
        {
          "n": "Bad Girl",
          "d": "03:44",
          "uid": "spotify:track:1sei51TK8wdPNc8tmwsrSc"
        },
        {
          "n": "Let It Go",
          "d": "04:40",
          "uid": "spotify:track:22FrNStyxnmALOpBJFXWyk"
        }
      ],
      "aN": "Lady Wray",
      "aU": "1plioVQ0mcgAO7uhvWkJJy"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273ce1455251bfb5e0245c77bc8",
      "t": [
        {
          "n": "Another Lifetime",
          "d": "03:29",
          "uid": "spotify:track:48WTGGIeSFD5ZMF51Rm4Y9"
        },
        {
          "n": "Make It Out Alive (feat. SiR)",
          "d": "04:59",
          "uid": "spotify:track:0VXinRGqxFxr1BKrOrC9pP"
        },
        {
          "n": "If You Ever",
          "d": "04:40",
          "uid": "spotify:track:5qbSSuBorHMw2wXC3qPe2Z"
        },
        {
          "n": "When Saturn Returns - Interlude",
          "d": "01:59",
          "uid": "spotify:track:7F23U974sp3gkkCTA4gJ4M"
        },
        {
          "n": "Saturn (feat. Kwabs)",
          "d": "05:50",
          "uid": "spotify:track:7HHlagS4aGF82LduE2FoY4"
        },
        {
          "n": "Gabriel",
          "d": "04:51",
          "uid": "spotify:track:5fp8Ww74MLFXjCYRxf6YMt"
        },
        {
          "n": "Orbit",
          "d": "04:54",
          "uid": "spotify:track:5yrXolC7Un3peiFxwqbucn"
        },
        {
          "n": "Love Supreme",
          "d": "04:16",
          "uid": "spotify:track:591qGFsTHMPHQ9V6lz4CKJ"
        },
        {
          "n": "Curiosity",
          "d": "04:36",
          "uid": "spotify:track:6j1owOuV2iTquW5vTw1fm3"
        },
        {
          "n": "Drive and Disconnect",
          "d": "04:30",
          "uid": "spotify:track:6pEAd0UjznaKABT7WLLvmC"
        },
        {
          "n": "Don't Change",
          "d": "03:28",
          "uid": "spotify:track:3tyB3Y7sfc02VwtsnW3aCO"
        },
        {
          "n": "Yellow of the Sun",
          "d": "04:51",
          "uid": "spotify:track:1sopAWv0BToiOT2wAunyuV"
        },
        {
          "n": "A Life Like This",
          "d": "04:38",
          "uid": "spotify:track:7c8bCcNTQTx13FkjtKkb8E"
        }
      ],
      "aN": "Nao",
      "aU": "7aFTOGFDEqDtJUCziLVsVC"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273b738999a454f126cb39b3b1c",
      "t": [
        {
          "n": "Night Walk",
          "d": "04:18",
          "uid": "spotify:track:3CKXSzkxqgNMrM5YTR1qKB"
        }
      ],
      "aN": "Gold Fir",
      "aU": "4dyk18v6VAa3Yb593eqmcE"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273bf818d032f92466cd2ab9e2c",
      "t": [
        {
          "n": "Too Fast",
          "d": "04:35",
          "uid": "spotify:track:0gqG3JmjuP4Pk8rIMwRCUJ"
        }
      ],
      "aN": "Yeek",
      "aU": "5BhFZpE8kUGZJiKOsYjLQM"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2732aebf42d8901fbcd14c9eca8",
      "t": [
        {
          "n": "Before Paris",
          "d": "02:30",
          "uid": "spotify:track:4D5POIvEJfBH8wO80Ic4T8"
        },
        {
          "n": "Lost in Paris",
          "d": "03:14",
          "uid": "spotify:track:4A7DUET5H4f7dJkUhjfVFB"
        },
        {
          "n": "South of the River",
          "d": "04:30",
          "uid": "spotify:track:5w3yxRRxy5pvZdUvBJF6ve"
        },
        {
          "n": "Movie",
          "d": "06:57",
          "uid": "spotify:track:6pxElwU80zhjbCC77Vn8EI"
        },
        {
          "n": "Tick Tock",
          "d": "04:14",
          "uid": "spotify:track:3al8a3uZrOZIHc6J1n8i5f"
        },
        {
          "n": "It Runs Through Me",
          "d": "04:22",
          "uid": "spotify:track:02CygBCQOIyEuhNZqHHcNx"
        },
        {
          "n": "Isn't She Lovely",
          "d": "01:27",
          "uid": "spotify:track:23H8PpuhyTDHwpqcDm7vS6"
        },
        {
          "n": "Disco Yes",
          "d": "05:41",
          "uid": "spotify:track:61Ivix5DTnDPVjp1dgLyov"
        },
        {
          "n": "Man Like You",
          "d": "05:41",
          "uid": "spotify:track:673BqQR0tNM3VtzcV3Ul2Q"
        },
        {
          "n": "Water Baby",
          "d": "05:32",
          "uid": "spotify:track:6Pd20wirRDM9k4e69px3dN"
        },
        {
          "n": "You're On My Mind",
          "d": "04:19",
          "uid": "spotify:track:0ORL2BIQwHdshE8Zp2En2M"
        },
        {
          "n": "Cos I Love You",
          "d": "04:14",
          "uid": "spotify:track:58xN31xmYcfrgA56gAeM3W"
        },
        {
          "n": "We've Come So Far",
          "d": "04:53",
          "uid": "spotify:track:46mMjdrfaJicOdrOA7NtBa"
        }
      ],
      "aN": "Tom Misch",
      "aU": "1uiEZYehlNivdK3iQyAbye"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273a55f73b70360daa13f3f30c2",
      "t": [
        {
          "n": "Wish You Were Gone",
          "d": "04:21",
          "uid": "spotify:track:3PTW5X4BlDqVkxNoTTqBqb"
        },
        {
          "n": "Chronic Sunshine",
          "d": "05:31",
          "uid": "spotify:track:3pnGJPnBptOIEa4bvdcLlG"
        },
        {
          "n": "After School Club",
          "d": "05:15",
          "uid": "spotify:track:7BpBtD7M2gVdAnKBkhSWPc"
        },
        {
          "n": "Social Sites",
          "d": "05:49",
          "uid": "spotify:track:4jE1fmY1evwHShz81sCZlv"
        },
        {
          "n": "Great Dane",
          "d": "08:58",
          "uid": "spotify:track:6OCFXXVmoPFtidXA7ey1SI"
        }
      ],
      "aN": "Cosmo Pyke",
      "aU": "1RKG6WXRzmTJtbLRZTPU0T"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2734102c5c0e3ec0b9ea6eeeb35",
      "t": [
        {
          "n": "Intro~",
          "d": "03:33",
          "uid": "spotify:track:6tONDRvH1PwW5B7YjCLCHB"
        },
        {
          "n": "~Outro",
          "d": "02:23",
          "uid": "spotify:track:4tH7qusSwqxCjx4c4tphtE"
        },
        {
          "n": "Stranger",
          "d": "04:38",
          "uid": "spotify:track:4MQwH8UtOM4qgJxd16kJX5"
        },
        {
          "n": "Some Feeling",
          "d": "03:17",
          "uid": "spotify:track:5e0b8UxDpZQro2cUCtK29Q"
        },
        {
          "n": "Mysight",
          "d": "04:19",
          "uid": "spotify:track:3y54TlZtGwtHapnvGEnwGX"
        },
        {
          "n": "Down By The River",
          "d": "04:57",
          "uid": "spotify:track:50jPA11pFqdxB1wMK9Fz9h"
        },
        {
          "n": "Selfish Lover",
          "d": "05:45",
          "uid": "spotify:track:7gWvM2Ffp63wX3NlcssJ9N"
        },
        {
          "n": "Losing Time",
          "d": "05:41",
          "uid": "spotify:track:6qfLL2ZoxIpqfzxrqXqEjP"
        },
        {
          "n": "In The Living Room",
          "d": "04:52",
          "uid": "spotify:track:6eXUUOfhAh6m7Udp53NE0W"
        },
        {
          "n": "Where Are We Now?",
          "d": "05:52",
          "uid": "spotify:track:5eYPrjCCB5qejaeArNGfpI"
        },
        {
          "n": "Terandara",
          "d": "03:27",
          "uid": "spotify:track:3Gdg0B64ZBIu1KIUM7JPzS"
        }
      ],
      "aN": "Mild Orange",
      "aU": "6yXBFHhojjdwKoop55NsHf"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b2734a42166d927b3acce345c5c0",
      "t": [
        {
          "n": "3 Nights",
          "d": "03:58",
          "uid": "spotify:track:1tNJrcVe6gwLEiZCtprs1u"
        },
        {
          "n": "She Wants My Money",
          "d": "02:14",
          "uid": "spotify:track:2VMJkgrhqfOOYBlZif2nvX"
        },
        {
          "n": "Babydoll",
          "d": "02:38",
          "uid": "spotify:track:1SocftHhtuqF7k83eUhHiz"
        },
        {
          "n": "Westcoast Collective",
          "d": "02:47",
          "uid": "spotify:track:582ndoUAn4YIN30NUnK6S2"
        },
        {
          "n": "Socks",
          "d": "02:11",
          "uid": "spotify:track:32KU85vllRfxfaV7ZNvHwT"
        },
        {
          "n": "King of Everything",
          "d": "03:14",
          "uid": "spotify:track:5IWW129DwGyMVQAbaJz3rS"
        }
      ],
      "aN": "Dominic Fike",
      "aU": "6USv9qhCn6zfxlBQIYJ9qs"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273f11f1c4ad183b7fa625f8534",
      "t": [
        {
          "n": "Start",
          "d": "01:46",
          "uid": "spotify:track:6KkCuHNbOAWJzycgOEGpIg"
        },
        {
          "n": "Thinkin Bout You",
          "d": "03:21",
          "uid": "spotify:track:5mphdlILgAq3vh1MSvAJTS"
        },
        {
          "n": "Fertilizer",
          "d": "01:40",
          "uid": "spotify:track:5MXB4YBEm0GZwS9Nbs3JqM"
        },
        {
          "n": "Sierra Leone",
          "d": "02:29",
          "uid": "spotify:track:4XgpXhvf9JBbKPtX84DFN7"
        },
        {
          "n": "Sweet Life",
          "d": "04:23",
          "uid": "spotify:track:6fbjdXZNtoAJbJZUeT87Ii"
        },
        {
          "n": "Not Just Money",
          "d": "01:60",
          "uid": "spotify:track:3VPmKgOCy3NGyyA4xaWwPd"
        },
        {
          "n": "Super Rich Kids",
          "d": "05:05",
          "uid": "spotify:track:0K9oqDmJBgSFjXU1bUY9Fk"
        },
        {
          "n": "Pilot Jones",
          "d": "03:04",
          "uid": "spotify:track:5ITIiswssMSAdTJ9ZDEI8D"
        },
        {
          "n": "Crack Rock",
          "d": "04:44",
          "uid": "spotify:track:125FPswReMD9Ggvn69M7Ch"
        },
        {
          "n": "Pyramids",
          "d": "10:53",
          "uid": "spotify:track:0rbK15g3UsDTVy1EuwgKYz"
        },
        {
          "n": "Lost",
          "d": "04:54",
          "uid": "spotify:track:4L7jMAP8UcIe309yQmkdcO"
        },
        {
          "n": "White",
          "d": "01:16",
          "uid": "spotify:track:6j9pCKVaJYNF7AdaNVTAaE"
        },
        {
          "n": "Monks",
          "d": "03:20",
          "uid": "spotify:track:3YXVl3FvIrvhgSW9ME3qNf"
        },
        {
          "n": "Bad Religion",
          "d": "03:55",
          "uid": "spotify:track:6jy12gDerHRUSwiEhfs9C6"
        },
        {
          "n": "Pink Matter",
          "d": "04:29",
          "uid": "spotify:track:0C3W4yLCuyUxIEwkSpBO8H"
        },
        {
          "n": "Forrest Gump",
          "d": "03:15",
          "uid": "spotify:track:6RBAJlxHY9Ulvw2y7yk4aX"
        },
        {
          "n": "End",
          "d": "02:15",
          "uid": "spotify:track:3liAea2gyRKm8nWubcwsvl"
        }
      ],
      "aN": "Frank Ocean",
      "aU": "2h93pZq0e7k5yf4dywlkpM"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273a7695725012f01292f2877e0",
      "t": [
        {
          "n": "Assume Form",
          "d": "05:50",
          "uid": "spotify:track:7ce0vNBSiPNpGvGJ4sot4H"
        },
        {
          "n": "Mile High",
          "d": "03:14",
          "uid": "spotify:track:64ydkbrt0xhdJXRaam06Mc"
        },
        {
          "n": "Tell Them",
          "d": "03:28",
          "uid": "spotify:track:3nWCi6Npr1DJObl5hgZwt7"
        },
        {
          "n": "Into The Red",
          "d": "04:17",
          "uid": "spotify:track:69sxo1DMPHgsJs1KA5OMRh"
        },
        {
          "n": "Barefoot In The Park",
          "d": "04:31",
          "uid": "spotify:track:1F7ZElvJAvWKQ7UaPXg9cF"
        },
        {
          "n": "Can't Believe The Way We Flow",
          "d": "04:27",
          "uid": "spotify:track:0Q3HFb2L0Ydh8cFxM36Ltg"
        },
        {
          "n": "Are You In Love?",
          "d": "03:18",
          "uid": "spotify:track:0aKl9lBwUvRUuXvgdT7Pgj"
        },
        {
          "n": "Where's The Catch?",
          "d": "05:36",
          "uid": "spotify:track:5FYvk4lH8kLfRKHW8Ac0mL"
        },
        {
          "n": "I'll Come Too",
          "d": "04:42",
          "uid": "spotify:track:0T3AyN1HbAlRScx2hTMScG"
        },
        {
          "n": "Power On",
          "d": "04:06",
          "uid": "spotify:track:6eykhAkF0Ml7aBCJdiAYf7"
        },
        {
          "n": "Don't Miss It",
          "d": "05:59",
          "uid": "spotify:track:5Q2LXkoqv8REmtHuXhbjJI"
        },
        {
          "n": "Lullaby For My Insomniac",
          "d": "04:44",
          "uid": "spotify:track:3yGJfVaVJdQn8AKoHh62ct"
        }
      ],
      "aN": "James Blake",
      "aU": "53KwLdlmrlCelAZMaLVZqU"
    },
    {
      "i": "https://i.scdn.co/image/ab67616d0000b273287af0e46fe70c8dc6c47609",
      "t": [
        {
          "n": "Release Your Problems",
          "d": "03:13",
          "uid": "spotify:track:4IrwwrvilWDSEP38LUEcVl"
        },
        {
          "n": "Talk Is Cheap",
          "d": "04:38",
          "uid": "spotify:track:0240T0gP9w6xEgIciBrfVF"
        },
        {
          "n": "No Advice - Airport Version",
          "d": "02:45",
          "uid": "spotify:track:08pv23Z6uuRlMjz0e9HuMJ"
        },
        {
          "n": "Melt",
          "d": "04:11",
          "uid": "spotify:track:7F9NJCMko9LLUrHxBS2Spb"
        },
        {
          "n": "Gold",
          "d": "05:45",
          "uid": "spotify:track:1g7zNtcGrWt8gcBRwDQEkf"
        },
        {
          "n": "To Me",
          "d": "05:15",
          "uid": "spotify:track:7v4vFLq2syogKodEaMrpYe"
        },
        {"n": "/", "d": "00:19", "uid": "spotify:track:1V4igmUU7t0LBaCETArqsb"},
        {
          "n": "Blush",
          "d": "05:47",
          "uid": "spotify:track:6Ny6ZruYFAkcskjqpSvrdX"
        },
        {
          "n": "1998",
          "d": "06:05",
          "uid": "spotify:track:0iHwnccPp214om2eGT5gzm"
        },
        {
          "n": "Cigarettes & Loneliness",
          "d": "08:52",
          "uid": "spotify:track:63YsXakppvKl1MsCYcn4zV"
        },
        {
          "n": "Lesson In Patience",
          "d": "06:46",
          "uid": "spotify:track:0CpntTz4Mon5NXycUkc6GO"
        },
        {
          "n": "Dead Body",
          "d": "04:54",
          "uid": "spotify:track:4gFWzCATnOfBkyJM8tpU3b"
        }
      ],
      "aN": "Chet Faker",
      "aU": "6UcJxoeHWWWyT5HZP064om"
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

  getDevices() async {
    HttpsCallableResult result =
        await FirebaseFunctions.instance.httpsCallable("getDevices").call();
    print(result);
  }
}
