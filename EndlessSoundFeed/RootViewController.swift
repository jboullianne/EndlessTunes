//
//  RootViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/16/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import UserNotifications

class RootViewController: UIViewController, NowPlayingBarDelegate {
    

    @IBOutlet var heightConstant: NSLayoutConstraint!
    @IBOutlet var nowPlayingView: UIView!
    @IBOutlet var npPanGesture: UIPanGestureRecognizer!
    
    @IBOutlet var trackTitleLabel: UILabel!
    @IBOutlet var artistTitleLabel: UILabel!
    @IBOutlet var albumThumbnail: UIImageView!
    @IBOutlet var sourceThumbnail: UIImageView!
    
    var barVisible:Bool = true
    let slideDownTransition = SlideDownTransitionAnimator()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.npBarDelegate = self
        
        self.slideDownTransition.sourceViewController = self
        self.slideDownTransition.enterPanGesture = npPanGesture
        // Do any additional setup after loading the view.
        hideBar()
        
        setupNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func showBar(){
        print("INSIDE ROOT VIEW: SHOW BAR")
        
        if(!barVisible){
            UIView.animate(withDuration: 0.2, animations: {
                self.heightConstant.constant = 80
                self.nowPlayingView.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                print("Success: ", success)
                self.barVisible = true
            })
        }
    }
    
    func hideBar(){
        print("INSIDE ROOT VIEW: HIDE BAR")
        
        if(barVisible){
            UIView.animate(withDuration: 0.2, animations: {
                self.heightConstant.constant = 0
                self.nowPlayingView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                print("Success: ", success)
                self.barVisible = false
            })
        }
    }
    
    func setTrack(track: Track){
        print("Setting Track on Now Playing Bar")
        trackTitleLabel.text = track.title
        artistTitleLabel.text = track.author
        albumThumbnail.image = track.thumbnailImage
        
        //Load External Thumbnail if it Exists
        if(track.thumbnailURL != "" && track.thumbnailImage == nil){
            
            Alamofire.request(track.thumbnailURL).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        self.albumThumbnail.image = image
                    }
                    
                    //Set Image Inside Track
                    MediaManager.sharedInstance.currentTrack?.thumbnailImage = image
                }
            }
        }
        
        switch(track.source){
            case .SoundCloud:
                sourceThumbnail.image = UIImage(named: "soundcloud")
                break
            case .Spotify:
                sourceThumbnail.image = UIImage(named: "Spotify_Logo_RGB_Green")
                break
        }
        
        DispatchQueue.main.async {
            self.showBar()
        }
    }
    
    func setupNotifications(){
        let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_,_ in })
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.application.registerForRemoteNotifications()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("SEGUEING!!!")
        if(segue.identifier == "showNowPlaying"){
            let toViewController = segue.destination as! NPViewController
            toViewController.transitioningDelegate = slideDownTransition
            
            slideDownTransition.destinationViewController = toViewController
            slideDownTransition.dismissPanGesture = toViewController.dismissPanGesture
        }
        
        if(segue.identifier == "showNowPlayingTap"){
            let toViewController = segue.destination as! NPViewController
            toViewController.transitioningDelegate = slideDownTransition
            
            slideDownTransition.destinationViewController = toViewController
            slideDownTransition.dismissPanGesture = toViewController.dismissPanGesture
        }
    }
    
    
}

protocol NowPlayingBarDelegate {
    func showBar()
    func hideBar()
    func setTrack(track: Track)
}

