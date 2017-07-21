//
//  SPViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/6/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class SPViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    //var auth = SPTAuth.defaultInstance()!
    //var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    let manager = MediaManager.sharedInstance

    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup()
        NotificationCenter.default.addObserver(self, selector: #selector(SPViewController.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateAfterFirstLogin(){
        print("UPDATE AFTER FIRST LOGIN IN SPVIEW CONTROLLER")
        
        let ac = UIAlertController(title: "Import Content", message: "Would you like to import your Spotify Playlists to Endless Tunes?", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "YES", style: .default) { (action) in
            print("User chose YES to import playlists")
            AccountManager.sharedInstance.startImport()
        }
        
        let noButton = UIAlertAction(title: "NO", style: .cancel) { (action) in
            print("User chose NOT to import playlists")
        }
        
        ac.addAction(yesButton)
        ac.addAction(noButton)
        self.present(ac, animated: true, completion: nil)
        
        
        //SPTPlaylistList.createRequestForGettingPlaylists(forUser: , withAccessToken: session!.accessToken)
    }
    
    /*
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }*/
    /*
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:2p4p9YGwmJIdf5IA9sSWhm", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
    }
    */
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func setup(){
        SPTAuth.defaultInstance().clientID          = "64cc78e5b2384aaeb6b0272bc6ab70b1"
        SPTAuth.defaultInstance().redirectURL       = URL(string: "EndlessSoundFeed://spotifyReturnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes   = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }*/
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.manager.loginSpotify()
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
