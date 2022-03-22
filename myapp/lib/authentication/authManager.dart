import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/aspects/failures/authFailure.dart';
import 'package:myapp/aspects/failures/failure.dart';
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
    DocumentReference userReference = firestore.collection('user').doc(userID);
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
        .collection("user")
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

  ///public

  Future<void> registerUserAndPassFirebase(
    BuildContext context, {
    @required String email,
    @required String password,
    @required String name,
  }) async {
    email ="maria@maria.maria";
    name = "Maria";
    password = "dengue";
    try {
      dynamic cid = await firestore.collection("artists").doc("HSYmqTuHsW1ALRdSzkv5").get();
      print(cid.name);
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userRef = firestore.collection('users').doc(userCredential.user.uid);

      DocumentSnapshot userDoc = await userRef.get();
      while (userDoc.data() == null) {
        await Future.delayed(Duration(milliseconds: 100));
        userDoc = await userRef.get();
      }
      userRef.update({
        "name": name,
        "timestamp": DateTime.now().toString()
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
    }
    on Exception catch(e){
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
}
