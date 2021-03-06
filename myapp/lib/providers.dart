import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/home/musicManager.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/objects/Profile.dart';
import 'package:myapp/objects/music/Playlist.dart';
import 'package:myapp/objects/music/Song.dart';
// Instance Providers

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final authProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final storageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
);
final connectivityProvider = StreamProvider<ConnectivityResult>(
  (ref) => Connectivity().onConnectivityChanged,
);

// Object Providers

final userStreamProvider = StreamProvider<Profile>(
  (ref) => ref.watch(authManagerProvider).profile,
);

final partyStreamProvider = StreamProvider<Playlist>(
  (ref) => ref.watch(partyManagerProvider).party,
);

final musicStreamProvider = StreamProvider<List<Song>>(
  (ref) => ref.watch(musicManagerProvider).music,
);
final musicProvider = Provider<List<Song>>(
  (ref) => ref.watch(musicStreamProvider).value,
);