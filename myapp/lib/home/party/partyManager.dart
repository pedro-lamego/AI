import 'dart:async';
import 'dart:math';

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

  StreamSubscription<QuerySnapshot> partyStreamSubscription;

  BehaviorSubject<Playlist> _partyStream = BehaviorSubject<Playlist>();
  Stream<Playlist> get party => _partyStream.stream;

  PartyManager(this._read);

  setUpPartyStream(String uid) async {
    if (!_firstTime) {
      await partyStreamSubscription.cancel();
      await _partyStream.close();
      _partyStream = BehaviorSubject<Playlist>();
    }
    DocumentSnapshot<Map<String, dynamic>> party =
        await firestore.collection("playlists").doc(uid).get();
    print(party.data()["uid"]);
    partyBloc = Playlist(
        party.data()["uid"],
        {},
        party.data()["name"],
        party.data()["owner"],
        party.data()["timestamp"],
        party.data()["isOpen"]); //handle restaurant
    partyStreamSubscription = firestore
        .collection("playlists")
        .doc(uid)
        .collection("songs")
        .snapshots()
        .listen((snapshot) async {
      for (DocumentChange docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          addSongToStream(docChange.doc);
        }
        if (docChange.type == DocumentChangeType.modified) {
          editSongToStream(docChange.doc);
        }
      }
      _partyStream.add(partyBloc);
      // if (partyBloc.isOpen == false) {
      //   partyStopped();
      // } see what to do with the admin party maybe handle restaurants
    });
  }

  addSongToStream(DocumentSnapshot<Object> doc) {
    PlaylistSong song = PlaylistSong.fromJson(doc.data());
    partyBloc.songs.addAll({doc.id: song});
  }

  editSongToStream(DocumentSnapshot<Object> doc) {
    print(doc);
    PlaylistSong song = PlaylistSong.fromJson(doc.data());
    partyBloc.songs[doc.id].downvotes = song.downvotes;
    partyBloc.songs[doc.id].upvotes = song.upvotes;
    partyBloc.songs[doc.id].alreadyPlayed = song.alreadyPlayed;
    partyBloc.songs[doc.id].playing = song.playing;
  }
  // General Functions

  createParty(String name) async {
    try {
      dynamic result = firestore.collection("playlists").doc();

      await firestore.collection("playlists").doc(result.id).set({
        "owner": authManager.userBloc.uid,
        "timestamp": DateTime.now().toIso8601String(),
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
    if (partyBloc.songs.containsKey(song.uid)) {
      upvoteSong(song.uid);
    } else {
      firestore
          .collection("playlists")
          .doc(partyBloc.uid)
          .collection("songs")
          .doc(song.uid)
          .set({
        "uid": song.uid,
        "downvotes": [],
        "upvotes": [],
        "artistName": song.artistName,
        "artistUid": song.artistUid,
        "duration": song.duration,
        "position": song.position,
        "album": song.album,
        "name": song.name,
        "srcImage": song.srcImage,
        "timestamp": DateTime.now().toIso8601String(),
        "alreadyPlayed": false,
        "playing": false,
      });
    }
  }

  upvoteSong(String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("upvote")
        .call({"playlistUid": partyBloc.uid, "songUid": songUid});
  }

  downvoteSong(String songUid) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("downvote")
        .call({"playlistUid": partyBloc.uid, "songUid": songUid});
  }

  joinPartyManager(String partyUid) async {
    await setUpPartyStream(partyUid);
    authManager.joinParty(partyUid);
  }

  partyStopped() async {
    authManager.addPlaylist(partyBloc);
    authManager.kickParty();
    _firstTime = false;
  }

  // Admin Functions

  stopParty() async {
    // startQueue();
    await firestore
        .collection("playlists")
        .doc(partyBloc.uid)
        .update({"isOpen": false});
  }

  changeQueue() {}

  playSong(String album, int position, String songUid) async {
    firestore
        .collection("playlists")
        .doc(partyBloc.uid)
        .collection("songs")
        .doc(songUid)
        .update({"playing": true});
    // HttpsCallableResult result =
    //     await FirebaseFunctions.instance.httpsCallable("playSong").call({
    //   "album": album,
    //   "position": position,
    // });
  }

  stopSong(String songUid) async {
    await firestore
        .collection("playlists")
        .doc(partyBloc.uid)
        .collection("songs")
        .doc(songUid)
        .update({"playing": false, "alreadyPlayed": true});
    // HttpsCallableResult result =
    //     await FirebaseFunctions.instance.httpsCallable("stopSong").call();
  }

  Future<List<Song>> sugestedSongs() async {
    List<String> artistList = [];
    List<Song> songList = [];
    List<Song> songListAux = [];
    if (partyBloc.songs.length > 2) {
      partyBloc.songs.forEach((_, value) {
        songListAux.add(value);
      });
      songListAux.shuffle();

      final random = Random();

      int i = random.nextInt(songListAux.length ~/ 2);
      int j = random.nextInt(
              songListAux.length ~/ 2 + (songListAux.length % 2 == 0 ? 0 : 1)) +
          (songListAux.length ~/ 2);

      for (; i <= j; i++) {
        artistList.add(songListAux[i].artistUid);
      }
    } else {
      return [];
    }

    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("sugestedSongs")
        .call({"artistList": artistList});
    for (dynamic song in result.data) {
      songList.add(Song(song.uid, song.name, song.duration, song.srcImage,
          song.artistName, song.artistUid, song.position, song.album));
    }
    return songList;
  }

  void startQueue() async {
    while (true) {
      List<PlaylistSong> songs = [];
      partyBloc.songs.forEach((_, value) => songs.add(value));
      songs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      songs.sort((a, b) => b.heuristic().compareTo(a.heuristic()));
      songs.removeWhere((song) => song.alreadyPlayed == true);
      if (songs.length == 0) continue;
      PlaylistSong song = songs[0];
      playSong(song.album, song.position, song.uid);
      List<String> duration = song.duration.split(":");
      await Future.delayed(Duration(
          minutes: int.parse(duration[0]), seconds: int.parse(duration[1])));
      await stopSong(song.uid);
    }
  }
}
