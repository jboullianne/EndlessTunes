//
//  MediaManager.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/3/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import FirebaseAnalytics

class MediaManager:NSObject, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate{
    
    static let sharedInstance = MediaManager()
    
    var nowPlayingDelegate:ESFNowPlayingDelegate?
    
    private var queue:[Track]
    var currentTrack:Track?
    var currentTime:CMTime?
    var durationTime:CMTime?
    
    var isPlaying:Bool
    
    private var playlist:Playlist?
    private var playlistIndex:Int?
    
    private var player:AVPlayer?
    
    //var session:SPTSession!
    var spotifyPlayer: SPTAudioStreamingController?
    var loginUrl: URL?
    
    
    
    override private init(){
        
        queue = []
        isPlaying = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaManager.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        setupPlaybackHandlers() //Playback handlers for Info Center
        
        //setupSpotify()
        retrieveSession()
        
        
        
    }
    
    //Decides Which Track To Play Next From Queue/playlist/Track
    private func playNextTrack(){
        if(!queue.isEmpty){
            //Play Next Track From Queue
            playTrack(track: queue[0])
            queue.remove(at: 0)
        }else if(playlistIndex != nil && playlistIndex! < (playlist?.tracks.count)!){
            //Play Next Track From the Playlist
            playTrack(track: (playlist?.tracks[playlistIndex!])!)
            playlistIndex! += 1
            
        }else{
            // What should I play next?
            print("No Next Track To Play...")
            self.isPlaying = false
        }
    }
    
    private func playPrevTrack(){
        if(playlistIndex != nil && playlistIndex! < (playlist?.tracks.count)!){
            //Play Next Track From the Playlist
            playlistIndex! -= 1
            if(playlistIndex! < 0){
                playlistIndex! = 0
            }
            playTrack(track: (playlist?.tracks[playlistIndex!])!)
            
            
        }
    }
    
    // Actually Plays track
    func playTrack(track: Track){
        pause()
        print("PLAY TRACK: ", track.title)
        self.currentTrack = track
        self.isPlaying = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.npBarDelegate?.setTrack(track: track)
        
        if(nowPlayingDelegate != nil){
            print("Notifying NPDelegate.")
            self.nowPlayingDelegate!.didStartPlayingTrack(track:track)
        }
        
        switch(track.source){
            case .Spotify:
                playSpotifyTrack(track: track)
                break;
            case .SoundCloud:
                playSoundCloudTrack(track: track)
                break;
        }
        
        //Create Activity Update
        let author = AccountManager.sharedInstance.currentUser?.displayName ?? "No Display Name"
        let authorUID = AccountManager.sharedInstance.currentUser?.uid ?? ""
        let date = Date()
        let event = ETEvent(type: .Activity, author: author, authorUID: authorUID, date: date)
        event.track = track
        
        print("ETEvent Created: Date \(event.dateString)")
        AccountManager.sharedInstance.logEvent(event: event)
        
        
        FIRAnalytics.logEvent(withName: "TrackPlay", parameters: ["name" : track.title, "author" : track.author, "source" : track.sourceString])
        ETDataManager.sharedInstance.addToRecents(track: track)
    }
    
    func playSpotifyTrack(track: Track){
        print("Starting Spotify Track")
        
        do{
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            //let artwork = MPMediaItemArtwork(image: #imageLiteral(resourceName: "ESF_logo"))
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [ MPMediaItemPropertyArtist: track.author,
                                                                MPMediaItemPropertyTitle: track.title,
                                                                MPNowPlayingInfoPropertyPlaybackRate: 1.0]
            MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
            
            
            
        }catch{
            
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let session = appDelegate.spSession {
            print("Session Present")
            print("Sesson Valid:", session.isValid())
            if(!session.isValid()){
                appDelegate.refreshSpotifySession {
                    self.updateAfterFirstLogin()
                    self.spotifyPlayer?.playSpotifyURI(track.uri, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                        if (error == nil) {
                            print("playing!")
                        }else{
                            print("Error Playing Spotify: ", error!)
                        }
                    })
                }
                
            }else{
                print("Session Valid. So Starting the track.")
                self.spotifyPlayer?.playSpotifyURI(track.uri, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                    }else{
                        print("Error Playing Spotify: ", error!)
                    }
                }) 
            }
            
        }
        
    }
    
    func playSoundCloudTrack(track: Track){
        print("Starting SoundCloud Track")
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            //let artwork = MPMediaItemArtwork(image: #imageLiteral(resourceName: "ESF_logo"))
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [ MPMediaItemPropertyArtist: track.author,
                                                                MPMediaItemPropertyTitle: track.title,
                                                                MPNowPlayingInfoPropertyPlaybackRate: 1.0]
            MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
            
            
            
        }catch{
            
        }
        
        self.player = AVPlayer(url: URL(string: track.uri)!)
        if let player = player{
            NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem!)
            player.volume = 1.0
            
            //Adds Time updates
            self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, 2), queue: DispatchQueue.main, using: { (time) in
                self.currentTime = time
                self.durationTime = self.player!.currentItem!.duration
                self.nowPlayingDelegate?.didReceiveTimeUpdate(time: time, duration: self.durationTime!)
            })
            
            player.play()
            
        }
    }
    
    //Adds Track To Queue
    func queueTrack(track:Track){
        print("Queued Track: ", track.title)
        queue.append(track)
    }
    
    //Adds Playlist and Plays First track
    func playPlaylist(playlist:Playlist){
        self.playlist = playlist
        self.playlistIndex = 1
        if(playlist.tracks.count > 0){
           playTrack(track: playlist.tracks[0])
        }
    }
    
    func play(){
        if(self.currentTrack != nil){
            self.isPlaying = true
            switch(self.currentTrack!.source){
            case .Spotify:
                self.spotifyPlayer?.setIsPlaying(true, callback: { (error) in
                    if(error != nil){
                        print("Success Playing Spotify:", error!)
                    }
                })
                break;
            case .SoundCloud:
                if let p = self.player{
                    p.play()
                }
                break;
            }
        }
    }
    
    func pause(){
        if(self.currentTrack != nil){
            self.isPlaying = false
            switch(self.currentTrack!.source){
            case .Spotify:
                self.spotifyPlayer?.setIsPlaying(false, callback: { (error) in
                    if(error != nil){
                        print("Success Pausing Spotify:", error!)
                    }
                })
                break;
            case .SoundCloud:
                if let p = self.player{
                    p.pause()
                }
                break;
            }
        }
    }
    
    func prev(){
        print("To-Do: MediaManager: Prev Track")
        self.playPrevTrack()
    }
    
    func next(){
        print("To-Do: MediaManager: Next Track")
        self.playNextTrack()
    }
    
    func seekTo(value: Float){
        print("Seeking To: \(value)")
    }
    
    func trackDidFinish(){
        print("Track Finished")
        playNextTrack()
    }
    
    //Playback Handlers for Info Center (swipe up on iPhone)
    func setupPlaybackHandlers(){
        MPRemoteCommandCenter.shared().playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            print("PLAY PRESSED:", event)
            self.play()
            return MPRemoteCommandHandlerStatus.success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            print("PAUSE PRESSED:", event)
            self.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            print("NEXT TRACK PRESSED:", event)
            return MPRemoteCommandHandlerStatus.success
        }
        
        MPRemoteCommandCenter.shared().likeCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            print("LIKE PRESSED", event)
            return MPRemoteCommandHandlerStatus.success
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    //-----------------------------
    //------SPOTIFY FUNCTIONS------
    //-----------------------------
    
    func retrieveSession(){
        /*if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            print("Retrieved Old Session. Session Valid:", firstTimeSession.isValid())
            if(!firstTimeSession.isValid()){
                SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
                    SPTAuth.defaultInstance().session = session
                    if error != nil {
                        print("*** Error renewing session: \(String(describing: error))")
                        return
                    }else{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.spSession = firstTimeSession
                        self.initializePlayer(authSession: firstTimeSession)
                        print("refreshed token")
                    }
                }
            }else{*/
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.spSession = firstTimeSession
        if let session = appDelegate.spSession {
            initializePlayer(authSession: session)
        }
        
            //}
            
            
        //}
    }
    
    
    
    func initializePlayer(authSession:SPTSession){
        
        if self.spotifyPlayer == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let auth = appDelegate.auth
            
            print("Initialize Player: Player Nil")
            self.spotifyPlayer = SPTAudioStreamingController.sharedInstance()
            self.spotifyPlayer!.playbackDelegate = self
            self.spotifyPlayer!.delegate = self
            try! spotifyPlayer!.start(withClientId: auth!.clientID)
            self.spotifyPlayer!.login(withAccessToken: authSession.accessToken!)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        _ = UIApplication.shared.delegate as! AppDelegate
        print("TOKEN Swap Service?: ", SPTAuth.defaultInstance().hasTokenSwapService, "TOKEN Refresh Service?:", SPTAuth.defaultInstance().hasTokenRefreshService)
        print("logged in")
    }
    
    func updateAfterFirstLogin(){
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.spSession = firstTimeSession
            
            print("MEDIAMANAGER: updateAfterFirstLogin")
            initializePlayer(authSession: appDelegate.spSession!)
            print("Session Refresh Token:", appDelegate.spSession!.encryptedRefreshToken)
        }
    }
    
    func loginSpotify(){
        self.loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        UIApplication.shared.open(loginUrl!, options: [:], completionHandler: { (success) in            
            if success && SPTAuth.defaultInstance().canHandle(SPTAuth.defaultInstance().redirectURL){
                // To do - build in error handling
                print("Did this work??")
            }
            else{
                print("MediaManager: Can't Open This.")
            }
        })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        print("Spotify Event:", event)
        
        switch(event){
        default:
            break
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        //print("Did Change Position")
        let duration = CMTimeMake(Int64(self.spotifyPlayer!.metadata.currentTrack!.duration), 1)
        nowPlayingDelegate?.didReceiveTimeUpdate(time: CMTimeMakeWithSeconds(position, 1), duration: duration)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Recieved Message")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        print("Did Seek To Position")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Did Stop Playing Spotify Track:")
        
        //End of Track or just stopping? IDK
        playNextTrack()
    }

    
}

protocol ESFNowPlayingDelegate {
    func didStartPlayingTrack(track:Track)
    func didReceiveTimeUpdate(time:CMTime, duration:CMTime)
}
