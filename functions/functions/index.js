const functions = require("firebase-functions");
const admin = require('firebase-admin');

var firebase_app = admin.initializeApp(functions.config().firebase);

exports.upvote = functions.https.onCall(async (data, context) => {
    /*
    data = {
        playlistUid : String
        songUid : String
    }
    */
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }

    let playlist = await admin.firestore().collection('playlists').doc(data.playlistUid).collection("songs").doc(data.songUid).get();

    let playlistData = playlist.data();


    for (var j = 0; j < playlistData.upvotes.length; j++) {
        if (playlistData.upvotes[j] === context.auth.uid) {
            return;
        }
    }

    playlistData.upvotes.push(context.auth.uid);

    playlistData.downvotes = playlistData.downvotes.filter(function (value) { return value !== context.auth.uid });

    admin.firestore().collection('playlists').doc(data.playlistUid).collection("songs").doc(data.songUid).set(playlistData);
    return;


});

exports.downvote = functions.https.onCall(async (data, context) => {
    /*
    data = {
        playlistUid : String
        songUid : String
    }
    */
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }
    let playlist = await admin.firestore().collection('playlists').doc(data.playlistUid).collection("songs").doc(data.songUid).get();

    let playlistData = playlist.data();


    for (var j = 0; playlistData.downvotes.length; j++) {
        if (playlistData.downvotes[j] === context.auth.uid) {
            return;
        }
    }

    playlistData.downvotes.push(context.auth.uid);

    playlistData.upvotes = playlistData.upvotes.filter(function (value) { return value !== context.auth.uid });

    admin.firestore().collection('playlists').doc(data.playlistUid).collection("songs").doc(data.songUid).set(playlistData);
    return;

});

exports.playSong = functions.https.onCall(async (data, context) => {

});

exports.stopSong = functions.https.onCall(async (data, context) => { });

exports.sugestedSongs = functions.https.onCall(async (data, context) => { });