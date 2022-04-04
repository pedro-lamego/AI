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

    let playlist = await admin.firestore().collection('playlists').doc(data.playlistUid).get();

    let playlistData = playlist.data();

    for (var i = 0; i < playlistData.songs.length; i++) {
        if (playlistData.songs[i].uid === data.songUid) {
            for (var j = 0; j < playlistData.songs[i].upvotes.length; j++) {
                if (playlistData.songs[i].upvotes[j] === context.auth.uid) {
                    return;
                }
            }

            playlistData.songs[i].upvotes.push(context.auth.uid);

            playlistData.songs[i].downvotes.filter(function (value) { return value !== context.auth.uid });

            admin.firestore().collection('playlists').doc(data.playlistUid).set(playlistData);
            return;

        }
    }
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
    let playlist = await admin.firestore().collection('playlists').doc(data.playlistUid).get();

    let playlistData = playlist.data();

    for (var i = 0; i < playlistData.songs.length; i++) {
        if (playlistData.songs[i].uid === data.songUid) {
            for (var j = 0; playlistData.songs[i].downvotes.length; j++) {
                if (playlistData.songs[i].downvotes[j] === context.auth.uid) {
                    console.log("entrou");
                    return;
                }
            }

            playlistData.songs[i].downvotes.push(context.auth.uid);

            playlistData.songs[i].upvotes.filter(function (value) { return value !== context.auth.uid });

            admin.firestore().collection('playlists').doc(data.playlistUid).set(playlistData);
            return;
        }
    }
});

exports.playSong = functions.https.onCall(async (data, context) => { 

});

exports.stopSong = functions.https.onCall(async (data, context) => { });

exports.sugestedSongs = functions.https.onCall(async (data, context) => { });