import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/PlaylistSong.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:rxdart/rxdart.dart';

final partyManagerProvider = Provider<PartyManager>(
  (ref) => PartyManager(ref.read),
);

class PartyManager {
  final Reader _read;

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);
  AuthManager get authManager => _read(authManagerProvider);

  Playlist partyBloc;
  bool _firstTime = true;

  StreamSubscription<DocumentSnapshot> partyStreamSubscription;

  BehaviorSubject<Playlist> _partyStream = BehaviorSubject<Playlist>();
  Stream<Playlist> get party => _partyStream.stream;

  PartyManager(this._read);

  setUpPartyStream(String uid) async {
    if (!_firstTime) {
      _partyStream = BehaviorSubject<Playlist>();
    }
    partyStreamSubscription = firestore
        .collection("playlists")
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {
      print(snapshot.data());
      partyBloc = Playlist.fromJson(snapshot.data());
      partyBloc.uid = snapshot.id;
      _partyStream.add(partyBloc);
      if (partyBloc.isOpen == false) {
        print("vim daqui");
        partyStopped();
      }
    });
  }
  // General Functions

  createParty(String name) async {
    try {
      dynamic result = firestore.collection("playlists").doc();

      await firestore.collection("playlists").doc(result.id).set({
        "owner": authManager.userBloc.uid,
        "timestamp": DateTime.now().toIso8601String(),
        "songs": [],
        "name": name,
        "isOpen": true,
        "uid": result.id,
      });

      joinPartyManager(result.id);
    } catch (err) {
      print(err.toString());
    }
  }

  addSongToParty(Song song) {
    if (partyBloc.songs.contains(song)) {
      upvoteSong(authManager.userBloc.uid, song.uid);
    } else {
      firestore.collection("playlists").doc(partyBloc.uid).update({
        "songs": FieldValue.arrayUnion([
          {
            "uid": song.uid,
            "downvotes": [],
            "upvotes": [],
            "artistName": song.artistName,
            "artistUid": song.artistUid,
            "duration": song.duration,
            "name": song.name,
            "srcImage": song.srcImage,
          }
        ])
      });
    }
  }

  upvoteSong(String userUid, String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("upvote")
        .call({"songUid": userUid, "songUid": songUid});
  }

  downvoteSong(String userUid, String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("downvote")
        .call({"songUid": userUid, "songUid": songUid});
  }

  joinPartyManager(String partyUid) async {
    await setUpPartyStream(partyUid);
    authManager.joinParty(partyUid);
  }

  partyStopped() async {
    print("entrei");
    authManager.addPlaylist(partyBloc);
    authManager.kickParty();
    await partyStreamSubscription?.cancel();
    await _partyStream?.close();
    _firstTime = false;
    partyBloc = null;
  }

  // Admin Functions

  stopParty() async {
    await firestore
        .collection("playlists")
        .doc(partyBloc.uid)
        .update({"isOpen": false});
  }

  changeQueue() {}

  playSong(String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("playSong")
        .call({"songUid": songUid});
  }

  stopSong(String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("stopSong")
        .call({"songUid": songUid});
  }
}
