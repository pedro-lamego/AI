const functions = require("firebase-functions");
const admin = require('firebase-admin');
const fetch = require('node-fetch');

var firebase_app = admin.initializeApp(functions.config().firebase);

var host = "https://api.spotify.com/v1";
var client_id = "825a79f9b566490abdde1f72b669a481";
var client_secret = "43c8c10b8ed44a098f1172a73bf91446";
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
    /* 
    data = {
        songUid : String

    }
    */
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }
    try {
        var ref = await admin.firestore().collection("spotifyAuth").doc(context.auth.uid).get();
        var spotifyAuth = ref.data();

        var response = await fetch("https://api.spotify.com/v1/me/player/play?device_id=" + spotifyAuth.device, {
            body: JSON.stringify({"context_uri":data.album,offset:{position:data.position},"position_ms":0}),
            headers: {
              Accept: "application/json",
              Authorization: "Bearer " + spotifyAuth.token,
              "Content-Type": "application/json"
            },
            method: "PUT"
          })
        console.log(response)
        return;
    } catch (err) {
        console.log(err);
    }
});

exports.stopSong = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }
    try {
        
        var ref = await admin.firestore().collection("spotifyAuth").doc(context.auth.uid).get();
        var spotifyAuth = ref.data();

        var response = await fetch("https://api.spotify.com/v1/me/player/pause?device_id=" + spotifyAuth.device, {
            headers: {
              Accept: "application/json",
              Authorization: "Bearer " + spotifyAuth.token,
              "Content-Type": "application/json"
            },
            method: "PUT"
          })
        return ;
    } catch (err) {
        console.log(err);
    }
});

exports.sugestedSongs = functions.https.onCall(async (data, context) => { 
    /* 
    data = 
        {
            artists : String
            tracks : String
            owner : string
        }
    ]
    */
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }
    try {
        var ref = await admin.firestore().collection("spotifyAuth").doc(data.owner).get();
        var spotifyAuth = ref.data();
        console.log(data.owner);
        var response = await  fetch("https://api.spotify.com/v1/recommendations?limit=5&seed_artists="+ data.artists+"&seed_genres=rock&seed_tracks="+ data.tracks, {
            headers: {
              Accept: "application/json",
              Authorization: "Bearer " + spotifyAuth.token,
              "Content-Type": "application/json"
            }
          })
          console.log(response)
        var result = await response.json();
        console.log("Result is");
        console.log(result);

        tracksList = [];
        for( var i= 0; i < 5; i++){
            track ={
                "uid" : result.tracks[i].uri,
                "name" : result.tracks[i].name,
                "srcImage" : result.tracks[i].album.images[0].url,
                "artistUid" : result.tracks[i].artists[0].id,
                "artistName" : result.tracks[i].artists[0].name,
                "duration" : "04:20",
                "position" : result.tracks[i].track_number,
                "album" : result.tracks[i].album.uri,
            };
            tracksList.push(track);
        }
        console.log(tracksList);
        return tracksList;
    } catch (err) {
        console.log(err);
    }
    return false;
});

exports.getDevices = functions.https.onCall(async (data, context) => { 
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'only authenticated users can add requests'
        );
    }

    var ref = await admin.firestore().collection("spotifyAuth").doc(context.auth.uid).get();
    var spotifyAuth = ref.data();

    try {
        //result = await requestToken();
        //console.log(result);

        var myHeaders = new fetch.Headers();

        myHeaders.append("Content-Type", "application/json");
        myHeaders.append("Authorization", "Bearer " + spotifyAuth.token);

        var requestOptions = {
            method: 'GET',
            headers: myHeaders,
            redirect: 'follow'
        };

        var response = await fetch(host + "/me/player/devices/", requestOptions);
  
        var result = await response.json();

        admin.firestore().collection("spotifyAuth").doc(context.auth.uid).update({"device":result.devices[0].id })

        if (result.error_description !== undefined
            //&& result.error_description === "Invalid access token."
        ) {
            return false;
        }
        return result;
    } catch (err) {
        console.log(err);
    }

    return false;
});

async function requestToken() {
    try{
        var myHeaders = new fetch.Headers();

        myHeaders.append("Authorization", "Basic " + client_id + ':' + client_secret);
        myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

        var urlencoded = new URLSearchParams();
        urlencoded.append("grant_type" , "client_credentials")

        var requestOptions = {
            method: 'POST',
            headers: myHeaders,
            body: urlencoded,
            redirect: 'follow'
        };

        var response = await fetch("https://accounts.spotify.com/api/token", requestOptions);
        var result = await response.json();

        
        console.log(result);
        return result;
    }catch(err){
        console.log(err)
    }
    return false;
}

