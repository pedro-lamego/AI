import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/Song.dart';
import 'package:myapp/providers.dart';
import 'package:rxdart/rxdart.dart';

final musicManagerProvider = Provider<MusicManager>(
  (ref) => MusicManager(ref.read),
);

class MusicManager {
  final Reader _read;
  //TODO see if this is necessary
  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  List<Song> musicBloc;

  final _musicStream = BehaviorSubject<List<Song>>();
  Stream<List<Song>> get music => _musicStream.stream;

  MusicManager(this._read);

  setUpMusicStream(String uid) {
    firestore.collection("musics").snapshots().listen((snapshot) async {
      for (DocumentChange MusicChange in snapshot.docChanges) {
        if (MusicChange.type == DocumentChangeType.added) {
          await addMusicToList(MusicChange.doc);
        }
      }
      _musicStream.add(musicBloc);
    });
  }

  // General Functions

  addMusicToList(DocumentSnapshot<Object> doc) {
    Song song = Song.fromJson(doc.data());
    song.uid = doc.id;
    musicBloc.add(song);
  }
}
