//
//  AccountManager.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation
import Firebase

class AccountManager{
    static let sharedInstance = AccountManager()
    
    var playlistDelegate:ESFPlaylistDelegate?
    var homeDataDelegate:HomeScreenDataDelegate?
    var followerDataDelegate:FollowerDataDelegate?
    var followingDataDelegate:FollowingDataDelegate?
    var newsFeedDataDelegate:NewsFeedDataDelegate?
    
    
    var currentUser:FIRUser?
    var playlists:[Playlist]
    var followers:[[String]] = [] // [displayName, email, uid]
    var following:[[String]] = [] // [displayName, email, uid]
    var newsFeedItems:[ETEvent] = []
    
    var ref:FIRDatabaseReference
    
    var playlistHandle:UInt?
    var followerHandle:UInt?
    var followingHandle:UInt?
    var feedHandle:UInt?
    
    

    
    
    private init() {
        self.playlists = []
        ref = FIRDatabase.database().reference()
    }
    
    func setupNewUser(user:FIRUser){
        currentUser = user
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateString = formatter.string(from: date)
        let email = currentUser!.email!
        self.ref.child("users").child(currentUser!.uid).setValue(["username": email, "date-joined": dateString, "spotify-connected": false])
        self.ref.child("p_users").childByAutoId().setValue(["uid": currentUser?.uid, "email" : email, "displayname" : currentUser!.displayName!.lowercased()])
        loadUserData()
    }
    
    func loginUser(user:FIRUser) {
        self.currentUser = user
        self.loadUserData()
        
        if self.currentUser?.displayName == nil {
            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
            changeRequest?.displayName = user.email
            changeRequest?.commitChanges { (error) in
                if(error != nil){
                    print("Error Updating Display Name")
                }
                else{
                    print("Updated Display Name to Email")
                }
            }
        }else{
            print("Display Name Already Set)")
        }
    }
    
    func loginUser(email: String?, pass: String?,  callback: @escaping (Bool, String)->()){
        currentUser = nil
        
        if (email != nil) && (pass != nil) {
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                var errorString = "Error Logging In"
                if let err = error as NSError? {
                    
                    if let code = FIRAuthErrorCode(rawValue: err.code) {
                        switch code {
                        case .errorCodeUserNotFound:    //User Not Found
                            print("User Not Found!!")
                            errorString = "Incorrect Username or Password"
                        case .errorCodeInvalidEmail:    //Invalid Email
                            print("Invalid Email")
                            errorString = "Invalid Email"
                        default:
                            print("Error Code Not Recognized")
                        }
                        callback(false, errorString)
                    }
                    
                    
                }else{
                    print("Firebase Auth Success")
                    // Set New Data
                    self.currentUser = user
                    self.loadUserData()
                    
                    //callback to transition
                    callback(true, errorString)
                    
                    
                    
                }
            })
        }
        
        
        
    }
    
    func loadUserData(){
        
        //Clear All Current Data
        playlists.removeAll()
        
        
        
        //Playlist Handle
        playlistHandle = ref.child("/u_playlists/" + currentUser!.uid).queryOrderedByKey().observe(.value, with: { (snap) in
            if(snap.value! is NSNull){
                print("No more playlists")
            }else{
                //print("SNAP:", snap.value!)
                self.playlists.removeAll()
                
                for playlist in snap.children {
                    let temp = playlist as! FIRDataSnapshot
                    let details = temp.value as! NSDictionary
                    
                    let name = details["name"] as! String
                    
                    var tracks:[Track] = []
                    let rawTracks = details["tracks"] as? NSDictionary
                    
                    if(rawTracks != nil){
                        
                        for t in rawTracks! {
                            let temp = t.value as! NSDictionary
                            var source:TrackSource?
                            
                            switch(temp["source"] as! String){
                            case "SoundCloud":
                                source = TrackSource.SoundCloud
                                break
                            case "Spotify":
                                source = TrackSource.Spotify
                                break
                            default:
                                continue
                            }
                            let track = Track(title: temp["title"] as! String, author: temp["author"] as! String, thumbnailURL: temp["thumbnailURL"] as? String, uri: temp["uri"] as! String, source: source!)
                            tracks.append(track)
                        }
                    }
                    let new_playlist = Playlist(name: name, tracks: tracks, owner: self.currentUser!.uid, id: temp.key)
                    self.playlists.append(new_playlist)
                }
                
                //Reverses Playlists to be in chronological order
                self.playlists.reverse()
                
                if(self.playlistDelegate != nil){
                    self.playlistDelegate?.didReceivePlaylistUpdate()
                }
                if(self.homeDataDelegate != nil){
                    self.homeDataDelegate?.newDataRecieved()
                }
            }
        })
        
        //Followers Handle
        followerHandle = ref.child("/followers/" + currentUser!.uid).queryOrderedByKey().observe(.value, with: { (snap) in
            if(snap.value! is NSNull){
                print("User has no followers")
            }else{
                print("SNAP:", snap.value!)
                self.followers.removeAll()
                
                let flist = snap.value! as! NSDictionary
                for f in flist {
                    print("KEY:", f)
                    let details = f.value as! NSDictionary
                    
                    let displayName = details["display_name"] as! String
                    let email = details["email"] as! String
                    let uid = f.key as! String
                    self.followers.append([displayName, email, uid])
                    
                }
                if(self.homeDataDelegate != nil){
                    self.homeDataDelegate?.newDataRecieved()
                }
                if(self.followerDataDelegate != nil){
                    self.followerDataDelegate?.newFollowerDataReceived()
                }
            }
        })
        
        //News Feed Handle
        feedHandle = ref.child("/feed_data/\(currentUser!.uid)/").queryOrderedByKey().queryLimited(toFirst: 100).observe(.value, with: { (snapshot) in
            
            if(snapshot.value! is NSNull){
                print("User has no feed items")
            }else{
                //print("FEED SNAP CHILD:", snapshot.value!)
                self.newsFeedItems.removeAll()
                
                let flist = snapshot.value! as! NSDictionary
                for f in flist {
                    print("KEY:", f)
                    let details = f.value as! NSDictionary
                    
                    let rawType = details["type"] as! String
                    var type:ETEventType?
                    switch rawType {
                    case "Created Playlist":
                        type = ETEventType.CreatedPlaylist
                        break
                    case "Shared Playlist":
                        type = ETEventType.SharedPlaylist
                        break
                    default:
                        break
                    }
                    
                    if(type == .CreatedPlaylist || type == .SharedPlaylist){
                        let author = details["owner"] as! String
                        let authorUID = details["ownerId"] as! String
                        let dateString = details["timestamp"] as! String
                        let date = ETEvent.getDateFromString(dateString: dateString)
                        
                        let playlistID = details["playlistID"] as! String
                        let playlistName = details["playlistName"] as! String
                        let playlist = Playlist(name: playlistName, tracks: [], owner: authorUID, id: playlistID)
                        
                        let event = ETEvent(type: type!, author: author, authorUID: authorUID, date: date)
                        event.playlist = playlist
                        
                        self.newsFeedItems.append(event)
                    }else{
                        //IDK What to do here yet
                    }
  
                }
                //print("ALL NEWS FEED ITEMS: \(self.newsFeedItems)")
                
                if(self.newsFeedDataDelegate != nil){
                    self.newsFeedDataDelegate?.newActivityDataReceived()
                }

            }
        })
        
        
    }
    
    func createNewPlaylist(name:String){
        if(name == ""){
            return
        }
        
        let key = self.ref.child("playlists").childByAutoId().key
        let childUpdates = ["/playlists/\(key)": ["name": name, "owner": currentUser!.uid], "/u_playlists/\(self.currentUser!.uid)/\(key)": ["name":name]]
        
        
        ref.updateChildValues(childUpdates) { (error, updateRef) in
            if(error == nil){
                //Log Playlist Creation Event
                let author = self.currentUser?.displayName ?? self.currentUser!.uid
                let authorUID = self.currentUser!.uid
                let date = Date()
                let playlist = Playlist(name: name, tracks: [], owner: self.currentUser!.uid, id: key)
        
                let event = ETEvent(type: .CreatedPlaylist, author: author, authorUID: authorUID, date: date)
                event.playlist = playlist
                
                self.logEvent(event: event)
                FIRAnalytics.logEvent(withName: "PlaylistCreation", parameters: ["name" : name, "id" : key])
            }
        }
    }
    
    func create(newPlaylist name:String, withTrack track:Track){
        if(name == ""){
            return
        }
        
        let key = self.ref.child("playlists").childByAutoId().key
        let childUpdates = ["/playlists/\(key)": ["name": name, "owner": currentUser!.uid], "/u_playlists/\(self.currentUser!.uid)/\(key)": ["name":name]]
        
        
        ref.updateChildValues(childUpdates) { (error, updateRef) in
            if(error == nil){
                let tkey = self.ref.child("/u_playlists/\(self.currentUser!.uid)/\(key)/tracks/").childByAutoId().key
                
                let childUpdates = ["/u_playlists/\(self.currentUser!.uid)/\(key)/tracks/\(tkey)": ["title": track.title, "author": track.author, "thumbnailURL": track.thumbnailURL, "uri" : track.uri, "source": track.sourceString]]
                self.ref.updateChildValues(childUpdates)
                
                //Log Playlist Creation Event
                let author = self.currentUser?.displayName ?? self.currentUser!.uid
                let authorUID = self.currentUser!.uid
                let date = Date()
                let playlist = Playlist(name: name, tracks: [], owner: self.currentUser!.uid, id: key)
                
                let event = ETEvent(type: .CreatedPlaylist, author: author, authorUID: authorUID, date: date)
                event.playlist = playlist
                
                self.logEvent(event: event)
                FIRAnalytics.logEvent(withName: "PlaylistCreation", parameters: ["name" : name, "id" : key])
            }
        }
    }
    
    func deletePlaylist(playlist: Playlist){
        self.ref.child("/playlists/\(playlist.id)").removeValue()
        self.ref.child("/u_playlists/\(self.currentUser!.uid)/\(playlist.id)").removeValue()
    }
    
    func addTrack(toPlaylist track:Track, index:Int){
        print("Adding \(track.title) to Plalist \(playlists[index].name) ; \(playlists[index].id)")
        
        let playlist = playlists[index]
        
        let key = self.ref.child("/u_playlists/\(currentUser!.uid)/\(playlist.id)/tracks/").childByAutoId().key
        
        let childUpdates = ["/u_playlists/\(currentUser!.uid)/\(playlist.id)/tracks/\(key)": ["title": track.title, "author": track.author, "thumbnailURL": track.thumbnailURL, "uri" : track.uri, "source": track.sourceString]]
        ref.updateChildValues(childUpdates)
    }
    
    func logEvent(event: ETEvent){
        print("TO-DO: Logging Event:", event)
        
        switch event.type {
        case .Activity:
            print("Activity Update")
            logActivityEvent(event: event)
            break
        case .CreatedPlaylist, .SharedPlaylist:
            print("Other Event")
            logOtherEvent(event: event)
            break
        }
    }
    
    //Logs User Activity to Database
    func logActivityEvent(event: ETEvent){
        guard let track = event.track else {
            return
        }
        var allUpdates:Dictionary<String,Any> = [:]
        let update = ["timestamp": event.dateString, "track": track.title, "author": track.author, "thumbnailURL": track.thumbnailURL, "uri" : track.uri, "source": track.sourceString]
        
        //Post Most Recent Activity to Every Follower (Single Event, kept actively updated)
        for f in self.followers {
            let uid = f[2]
            allUpdates["/follower_activity/\(uid)/\(currentUser!.uid)"] = update
        }
        
        //Post Activity to User's Personal Activity History (Multiple Events, Pushed Actively)
        let ukey = self.ref.child("/u_activity/\(currentUser!.uid)/").childByAutoId().key
        //Finally Save Activity To User's Personal History
        allUpdates["/u_activity/\(currentUser!.uid)/\(ukey)/"] = update
        
        self.ref.updateChildValues(allUpdates)
    }
    
    // Logs Other News Feed Events to Database
    func logOtherEvent(event: ETEvent){
        
        var update:NSDictionary = [:]
        
        
        switch event.type {
        case .CreatedPlaylist:

            guard let playlist = event.playlist else {
                return
            }
            
            var allUpdates:Dictionary<String,Any> = [:]
            update = ["timestamp": event.dateString, "type": event.type.toString(), "owner": event.author, "ownerId": event.authorUID, "playlistID" : playlist.id, "playlistName": playlist.name]
            
            //Post Activity to Every Follower's News Feed (Multiple Events, Kept Actively Updated)
            for f in self.followers {
                let uid = f[2]
                let fkey = self.ref.child("/feed_data/\(uid)/").childByAutoId().key
                allUpdates["/feed_data/\(uid)/\(fkey)"] = update
            }
            //Also Save it to user's feed so they can see it worked.
            let fkey = self.ref.child("/feed_data/\(currentUser!.uid)/").childByAutoId().key
            allUpdates["/feed_data/\(currentUser!.uid)/\(fkey)"] = update
            
            //Finally Save Activity To User's Personal History
            let ukey = self.ref.child("/u_activity/\(currentUser!.uid)/").childByAutoId().key
            allUpdates["/u_activity/\(currentUser!.uid)/\(ukey)/"] = update
            
            //Upload Changes to Firebase Database
            self.ref.updateChildValues(allUpdates)
            break
        case .SharedPlaylist:
            guard let playlist = event.playlist else {
                return
            }
            
            var allUpdates:Dictionary<String,Any> = [:]
            update = ["timestamp": event.dateString, "type": event.type.toString(), "owner": event.author, "ownerId": event.authorUID, "playlistID" : playlist.id, "playlistName": playlist.name, "playlistOwner" : playlist.owner]
            
            //Post Activity to Every Follower's News Feed (Multiple Events, Kept Actively Updated)
            for f in self.followers {
                let uid = f[2]
                let fkey = self.ref.child("/feed_data/\(uid)/").childByAutoId().key
                allUpdates["/feed_data/\(uid)/\(fkey)"] = update
            }
            
            let ukey = self.ref.child("/u_activity/\(currentUser!.uid)/").childByAutoId().key
            //Finally Save Activity To User's Personal History
            allUpdates["/u_activity/\(currentUser!.uid)/\(ukey)/"] = update
            
            self.ref.updateChildValues(allUpdates)
            break
        default:
            break
        }
        
    }
    
    func importSpotifyPlaylists(sPlaylists: [Playlist]){
        //print("In Account Manager. Importing Playlists: \(sPlaylists)")
        
        var pUpdates:Dictionary<String,Any> = [:]
        var pKeys:[String] = []
        
        for p in sPlaylists {
            print("Tracks, \(p.tracks)")
            let pKey = self.ref.child("playlists").childByAutoId().key
            pUpdates["/playlists/\(pKey)"] =  ["name": p.name, "owner": currentUser!.uid]
            pUpdates["/u_playlists/\(self.currentUser!.uid)/\(pKey)"] =  ["name":p.name]
            pKeys.append(pKey)
        }
        
        //Push All Spotify Playlists to Firebase
        ref.updateChildValues(pUpdates)
        
        var tUpdates:Dictionary<String,Any> = [:]
        
        var x = 0
        for p in sPlaylists {
            for t in p.tracks {
                let tKey = self.ref.child("/u_playlists/\(currentUser!.uid)/\(pKeys[x])/tracks/").childByAutoId().key
                tUpdates["/u_playlists/\(currentUser!.uid)/\(pKeys[x])/tracks/\(tKey)"] = ["title": t.title, "author": t.author, "thumbnailURL": t.thumbnailURL, "uri" : t.uri, "source": t.sourceString]
            }
            x += 1
        }
        
        //Push All Spotify Playlists to Firebase
        ref.updateChildValues(tUpdates)
        
    }
    
    func clearAllUserData(callback: ()->()) {
        if(playlistHandle != nil) { self.ref.removeObserver(withHandle: playlistHandle!) }
        if(followerHandle != nil) { self.ref.removeObserver(withHandle: followerHandle!) }
        if(followingHandle != nil) { self.ref.removeObserver(withHandle: followingHandle!) }
        if(feedHandle != nil) { self.ref.removeObserver(withHandle: feedHandle!) }
        
        self.currentUser = nil
        self.playlists.removeAll()
        self.followers.removeAll()
        self.following.removeAll()
        
        
        //Purge Data From All Manager Here
        ETDataManager.sharedInstance.purgeData()
        
        callback()
    }
    
    func attachDeviceTokenToUser(token: String) {
        if let user = self.currentUser {
            self.ref.child("/users/\(user.uid)/device_token").setValue([token: true])
        }
    }
    
    func startImport() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //let auth = delegate.auth
        let session = delegate.spSession
        
        
        
        SPTUser.requestCurrentUser(withAccessToken: session!.accessToken) { (err, data) in
            if(err != nil){
                print("Error Retreiving User: \(err.debugDescription)")
                return
            }
            let user = data as! SPTUser
            let username = user.canonicalUserName
            SPTPlaylistList.playlists(forUser: username, withAccessToken: session!.accessToken, callback: { (err, data) in
                if(err != nil){
                    print("Error Retreiving Playlist List")
                    return
                }
                
                let playlistList = data as! SPTPlaylistList
                self.parseSpotifyData(items: playlistList.items, playlistList: playlistList, listPage: nil)
                
            })
        }
    }
    
    func parseSpotifyData(items: [Any], playlistList:SPTPlaylistList?, listPage: SPTListPage?) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //let auth = delegate.auth
        let session = delegate.spSession
        
        var uriList:[URL] = []
        
        for pl in items {
            print("PL: \(pl)")
            let partial =  pl as! SPTPartialPlaylist
            let uri = partial.uri
            
            if let url = uri {
                uriList.append(url)
            }
            
        }
        print("URI LIST COUNT: \(uriList.count)")
        
        SPTPlaylistSnapshot.playlists(withURIs: uriList, accessToken: session!.accessToken, callback: { (err, data) in
            
            var importedPlaylists:[Playlist] = []
            
            //print("Data URIs \(data)")
            let data = data as! NSArray
            for d in data {
                let snapshot = d as! SPTPlaylistSnapshot
                let tracks = snapshot.tracksForPlayback()
                let name = snapshot.name ?? ""
                let playlist = Playlist(name: name, tracks: [], owner: "", id: "")
                
                if let tracks = tracks {
                    print("Track Count: \(tracks.count)")
                    for t in tracks {
                        let item = t as! SPTPlaylistTrack
                        
                        let artist = (item.artists[0] as! SPTPartialArtist).name!
                        let title = item.name!
                        //let cover = item.album.largestCover
                        var thumbnailURL:String? = nil
                        
                        if let cover = item.album.largestCover {
                            thumbnailURL = cover.imageURL.absoluteString
                        }else{
                            for c in item.album.covers {
                                if let cover = c as? SPTImage {
                                    if thumbnailURL == nil {
                                        thumbnailURL = cover.imageURL.absoluteString
                                    }
                                }
                            }
                        }
                        
                        if thumbnailURL == nil {
                            thumbnailURL = ""
                        }
                        
                        let uri = item.uri.absoluteString
                        let track = Track(title: title, author: artist, thumbnailURL: thumbnailURL!, uri: uri, source: .Spotify)
                        
                        playlist.tracks.append(track)
                        
                    }
                    importedPlaylists.append(playlist)
                    print("IMPORTED PLAYLISTS: \(importedPlaylists)")
                }
                
            }
            //Reverse the Imported Playlists to Be In Chronological order
            importedPlaylists.reverse()
            AccountManager.sharedInstance.importSpotifyPlaylists(sPlaylists: importedPlaylists)
        })
        
        
        if let list = playlistList{
            if(list.hasNextPage){
                list.requestNextPage(withAccessToken: session!.accessToken, callback: { (err, data) in
                    if(err != nil){
                        print("Error Retreiving Playlist List")
                        return
                    }
                    
                    let pList = data as! SPTListPage
                    let pData = pList.items
                    self.parseSpotifyData(items: pData!, playlistList: nil, listPage: pList)
                })
            }
        }
        
        if let lPage = listPage{
            if(lPage.hasNextPage){
                lPage.requestNextPage(withAccessToken: session!.accessToken, callback: { (err, data) in
                    if(err != nil){
                        print("Error Retreiving Playlist List")
                        return
                    }
                    
                    let pList = data as! SPTListPage
                    let pData = pList.items
                    self.parseSpotifyData(items: pData!, playlistList: nil, listPage: pList)
                })
            }
        }
        
        
        
    }
    
}

protocol ESFPlaylistDelegate {
    func didReceivePlaylistUpdate()
}

