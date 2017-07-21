//
//  NPViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage


class NPViewController: UIViewController, ESFNowPlayingDelegate {
    
    @IBOutlet var albumBackground: UIImageView!
    @IBOutlet var albumForeground: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var dismissPanGesture: UIPanGestureRecognizer!
    
    var gradientLayer:CAGradientLayer!
    
    @IBOutlet var dismissIcon: UIImageView!
    
    //Seek Bar Outlets
    @IBOutlet var seekLeftLabel: UILabel!
    @IBOutlet var seekRightLabel: UILabel!
    @IBOutlet var seekBarSlider: UISlider!
    
    @IBOutlet var ppButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = albumBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        albumBackground.addSubview(blurEffectView)
        // Do any additional setup after loading the view.
        MediaManager.sharedInstance.nowPlayingDelegate = self
        
        createGradientLayer()
        
        dismissIcon.image = dismissIcon.image!.withRenderingMode(.alwaysTemplate)
        dismissIcon.tintColor = UIColor(red: 0, green: 38/255, blue: 69/255, alpha: 1.0)
        
        if MediaManager.sharedInstance.isPlaying {
            ppButton.image = UIImage(named: "icons8-Circled Pause Filled-100")
        }else{
            ppButton.image = UIImage(named: "icons8-Circled Play Filled-100")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let manager = MediaManager.sharedInstance
        if let track = manager.currentTrack{
            albumBackground.image = track.thumbnailImage
            albumForeground.image = track.thumbnailImage
            
            titleLabel.text = track.title
            authorLabel.text = track.author
            if let time = manager.currentTime, let duration = manager.durationTime{
                updateSeekbar(current: time, duration: duration)
            }
            
            //Load External Thumbnail if it Exists
            if(track.thumbnailURL != "" && track.thumbnailImage == nil){
                
                Alamofire.request(track.thumbnailURL).responseImage { response in
                    
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        
                        DispatchQueue.main.async {
                            self.albumBackground.image = image
                            self.albumForeground.image = image
                        }
                        
                        MediaManager.sharedInstance.currentTrack?.thumbnailImage = image
                        
                        //Set Image Inside Track
                    }
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func didStartPlayingTrack(track: Track) {
        if let image = track.thumbnailImage{
            albumBackground.image = image
            albumForeground.image = image
        }
        
        titleLabel.text = track.title
        authorLabel.text = track.author
    }
    
    func didReceiveTimeUpdate(time: CMTime, duration: CMTime) {
        print("NP Time:", time.durationText)
        updateSeekbar(current: time, duration: duration)
    }
    
    @IBAction func dismissNPController(_ sender: Any) {
        print("DISMISS NP CONTROLLER")
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        //End Color For The Buttons
        let endColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        gradientLayer.colors = [UIColor.clear.cgColor, endColor.cgColor ]
        gradientLayer.locations = [0.0, 0.55]
        
        self.albumBackground.layer.addSublayer(gradientLayer)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func seekValueChanged(_ sender: UISlider) {
        let val = sender.value
        MediaManager.sharedInstance.seekTo(value: val)
    }
    
    func updateSeekbar(current: CMTime, duration: CMTime){
        seekLeftLabel.text = current.durationText
        seekRightLabel.text = duration.durationText
        
        let seekBarValue = current.seconds/duration.seconds
        seekBarSlider.value = Float(seekBarValue)
    }
    
    // Play/Pause Pressed
    @IBAction func ppButtonPressed(_ sender: UITapGestureRecognizer) {
        print("NowPlaying: PPButtonPressed, \(MediaManager.sharedInstance.isPlaying)")
        if MediaManager.sharedInstance.isPlaying {
            MediaManager.sharedInstance.pause()
            ppButton.image = UIImage(named: "icons8-Circled Play Filled-100")
        }else{
            MediaManager.sharedInstance.play()
            ppButton.image = UIImage(named: "icons8-Circled Pause Filled-100")
        }
    }

    
    // Previous Button Pressed
    @IBAction func prevButtonPressed(_ sender: Any) {
        print("NowPlaying: PREV Button Pressed")
        MediaManager.sharedInstance.prev()
    }
    
    // Next Button Pressed
    @IBAction func nextButtonPressed(_ sender: Any) {
        print("NowPlaying: NEXT Button Pressed")
        MediaManager.sharedInstance.next()
    }
    

}

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "0:00"
        }
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if minutes > 9 {
            return String(format: "%02i:%02i", minutes, seconds)
        } else {
            return String(format: "%01i:%02i", minutes, seconds)
        }
    }
}
