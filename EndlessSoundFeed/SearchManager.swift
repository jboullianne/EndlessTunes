//
//  SearchManager.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import AVFoundation
import FirebaseDatabase

class SearchManager{
    static let sharedInstance = SearchManager()
    
    struct ETUser {
        var displayName:String
        var email:String
        var uid:String
    }
    
    var soundCloudResults:[Track]
    var spotifyResults:[Track]
    var allPartiesResults:[PartyManager.ETParty]
    var spPartiesResults:[PartyManager.ETParty]
    var collabPartiesResults:[PartyManager.ETParty]
    var userResults:[ETUser]
    var friendResults:[ETUser]
    
    var homeTracks:[Track]
    var player:AVPlayer?
    
    var lastTrackQuery:String = ""
    var lastPartyQuery:String = ""
    var lastUserQuery:String = ""
    
    private init() {
        self.spotifyResults = []
        self.soundCloudResults = []
        self.allPartiesResults = []
        self.spPartiesResults = []
        self.collabPartiesResults = []
        self.friendResults = []
        self.userResults = []
        self.homeTracks = []
        self.player = AVPlayer()
    }
    
    func attachImageToTrack(image:UIImage, url:String){
        for track in spotifyResults{
            if track.thumbnailURL == url{
                track.thumbnailImage = image
            }
        }
        
        for track in soundCloudResults{
            if track.thumbnailURL == url{
                track.thumbnailImage = image
            }
        }
    }
    
    //Query SoundCloud / Spotify Tracks
    func queryTracks( q:String, callback: @escaping ()->()){
        print("SearchManager: Query Tracks! q=\(q)")
        if lastTrackQuery != q {
            querySoundCloud(query: q) {
                callback()
            }
            
            querySpotify(query: q) { 
                callback()
            }
            lastTrackQuery = q
        }else{
            callback()
        }
    }
    
    //Query Users From Firebase
    func queryUsers( q:String, callback: @escaping ()->()){
        print("SearchManager: Query Users! q=\(q)")
        
        if lastUserQuery != q {
            queryAllUsers(query: q) {
                callback()
            }
            
            queryFriends(query: q, owneruid: AccountManager.sharedInstance.currentUser!.uid) { 
                callback()
            }
            lastUserQuery = q
        }else{
            callback()
        }
        
    }
    
    //Query Parties From Firebase
    func queryParties( q:String, callback: @escaping ()->()){
        print("SearchManager: Query Parties! q=\(q)")
        
        if lastPartyQuery != q {
            queryAllParties(query: q) {
                callback()
            }
            lastPartyQuery = q
        }else{
            callback()
        }
    }

    func querySoundCloud(query:String, callback: @escaping ()->()){
        print("Starting Query with SoundCloud!")
        let sq = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        //print("SQ: ", sq)
        
        soundCloudResults.removeAll()
        
        Alamofire.request("https://api.soundcloud.com/tracks?q=\(sq!)&client_id=acba82beee52b1215da96546eb0fabb6").responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            print(response.result)   // result of response serialization
            //print(response.result.value)
            
            
            if let items = response.result.value as? NSArray{

                for i in items {
                    let item = i as! NSDictionary
                    
                    let streamable = item["streamable"] as! Bool
                    if !streamable {
                        continue
                    }
                    
                    let thumbnailURL = item["artwork_url"] as? String
                    
                    
                    
                    let title = item["title"] as! String
                    let author = (item["user"] as! NSDictionary)["username"] as! String
                    let uri = (item["stream_url"] as! String) + "?client_id=acba82beee52b1215da96546eb0fabb6"
                    
                    
                    //print("TITLE: ", title, author, thumbnailURL, uri)
                    
                    let track = Track(title: title, author: author, thumbnailURL: thumbnailURL, uri: uri, source: .SoundCloud)
                    self.soundCloudResults.append(track)
                }
                callback()
            }
        }
    }
    
    
    func querySpotify(query: String, callback: @escaping ()->()){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        guard let session = appDelegate.spSession else{
            return
        }
        
        spotifyResults.removeAll()
        
        SPTSearch.perform(withQuery: query,  queryType: .queryTypeTrack, accessToken: session.accessToken, callback: { (error, data) in
            if let result = data as? SPTListPage{
                
                guard (result.items) != nil else {
                    return
                }
                
                 for x in result.items {
                    let item = x as! SPTPartialTrack
                    let artist = (item.artists[0] as! SPTPartialArtist).name!
                    let title = item.name!
                    let smallThumbnail = item.album.smallestCover.imageURL.absoluteString
                    let thumbnailURL = item.album.largestCover.imageURL.absoluteString
                    let uri = item.uri.absoluteString
                    
                    let track = Track(title: title, author: artist, thumbnailURL: thumbnailURL, uri: uri, source: .Spotify)
                    track.smallThumbnailURL = smallThumbnail
                    self.spotifyResults.append(track)
                    print("ARTIST: ", artist)
                 }

                /*
                let track = result.items[0] as! SPTPartialTrack
                self.spotifyPlayer?.playSpotifyURI(track.uri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                    if (error != nil) {
                        print("playing!")
                    }
                })
                */
                
                
            }
        })
    }
    
    func queryAllUsers(query:String, callback: @escaping ()->()){
        print("Starting Query Against User List!")

        
        let _ = AccountManager.sharedInstance.ref.child("p_users").queryOrdered(byChild: "displayname").queryStarting(atValue: query.lowercased(), childKey: "displayname").queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snap) in
            
            self.userResults.removeAll()
            
            for user in snap.children {
                let temp = user as! FIRDataSnapshot
                if let details = temp.value as? NSDictionary{
                    let displayName = details["displayname"] as! String
                    let email = details["email"] as! String
                    let uid = details["uid"] as! String
                    
                    let uResult = ETUser(displayName: displayName, email: email, uid: uid)
                    self.userResults.append(uResult)
                }
                
                
            }
            
            print("Users Found: \(self.userResults)")
            callback()
        })
    }
    
    func queryFriends(query:String, owneruid: String, callback: @escaping ()->()){
        print("Starting Query Against User List!")
        
        
        let _ = AccountManager.sharedInstance.ref.child("/f_users/\(owneruid)/").queryOrdered(byChild: "displayname").queryStarting(atValue: query.lowercased(), childKey: "displayname").queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snap) in
            
            self.friendResults.removeAll()
            
            for user in snap.children {
                let temp = user as! FIRDataSnapshot
                if let details = temp.value as? NSDictionary{
                    let displayName = details["displayname"] as! String
                    let email = details["email"] as! String
                    let uid = details["uid"] as! String
                    
                    let uResult = ETUser(displayName: displayName, email: email, uid: uid)
                    self.friendResults.append(uResult)
                }
                
                
            }
            callback()
            print("Users Found: \(self.friendResults)")
        })
    }
    
    func queryAllParties(query: String, callback: @escaping ()->()) {
        let _ = AccountManager.sharedInstance.ref.child("/p_parties").queryOrdered(byChild: "name").queryStarting(atValue: query).queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snap) in
            self.allPartiesResults.removeAll()
            
            for party in snap.children {
                let temp = party as! FIRDataSnapshot
                if let details = temp.value as? NSDictionary{
                    let partyID = temp.key
                    let name = details["name"] as! String
                    let ownerID = details["owneruid"] as! String
                    let ownername = details["ownername"] as! String
                    let isPublic = true
                    let isSpotifyEnabled = details["sp_enabled"] as! Bool
                    let isCollaborative = details["collab"] as! Bool
                    let npThumbURL = details["np_thumb"] as? String
                    let userCount = details["u_count"] as! Int
                    
                    let pResult = PartyManager.ETParty(partyID: partyID, name: name, ownerID: ownerID, ownername: ownername, isPublic: isPublic, isSpotifyEnabled: isSpotifyEnabled, isCollaborative: isCollaborative, npThumbURL: npThumbURL, image: nil, userCount: userCount)
                    self.allPartiesResults.append(pResult)
                }
            }
            
            print("SORTED PARTIES: \(self.allPartiesResults)")
            
            //Sort The Parties Further
            self.buildSPParties()
            self.buildCollabParties()
            
            callback()
        })
    }
    
    func buildSPParties() {
        
        self.spPartiesResults.removeAll()
        
        for party in self.allPartiesResults {
            if party.isSpotifyEnabled {
                self.spPartiesResults.append(party)
            }
        }
    }
    
    func buildCollabParties() {
        
        self.collabPartiesResults.removeAll()
        
        for party in self.allPartiesResults {
            if party.isCollaborative {
                self.collabPartiesResults.append(party)
            }
        }
    }
    
    func playTrack(atIndex index:Int, section:Int){
        if section == 0 {
            let selectedTrack = soundCloudResults[index]
            MediaManager.sharedInstance.playTrack(track: selectedTrack)
        }else if section == 1{
            let selectedTrack = spotifyResults[index]
            MediaManager.sharedInstance.playTrack(track: selectedTrack)
        }
        
    }
    
    
}
