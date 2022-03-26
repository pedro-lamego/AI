import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/screens/JoinParty.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/providers.dart';
import 'package:rxdart/rxdart.dart';

final partyManagerProvider = Provider<PartyManager>(
  (ref) => PartyManager(ref.read),
);

class PartyManager {
  final Reader _read;
  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  Playlist partyBloc;

  final _partyStream = BehaviorSubject<Playlist>();
  Stream<Playlist> get party => _partyStream.stream;

  PartyManager(this._read);

  setUpPartyStream(String uid) {
    firestore
        .collection("playlists")
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {
      partyBloc = Playlist.fromJson(snapshot.data());
      partyBloc.uid = snapshot.id;
      _partyStream.add(partyBloc);
    });
  }
  // General Functions

  createParty(String name, String owner, DateTime dateTime) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable("createParty")
          .call({"name": name, "owner": owner, "dateTime": dateTime});
      setUpPartyStream(result.data.uid);
    } catch (err) {
      print(err.toString());
    }
  }

  upvoteSong(String songUid) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable("upvote")
          .call({"songUid": songUid, "partyUid": partyBloc.uid});
    } catch (err) {
      print(err.toString());
      //!
    }
  }

  downvoteSong(String songUid) async {
    try {
      HttpsCallableResult result = await FirebaseFunctions.instance
          .httpsCallable("downvote")
          .call({"songUid": songUid, "partyUid": partyBloc.uid});
    } catch (err) {
      print(err.toString());
      //todo barra
    }
  }

  joinParty(String partyUid) {
    setUpPartyStream(partyUid);
  }

  partyStopped(){
    //cancelar as subscricoes
    _partyStream.add(null);
  }

  // Admin Functions

  stopParty() async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("stopParty")
        .call({"partyUid": partyBloc.uid});
    partyStopped();
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