//
//  HomeViewController.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 6/18/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import TwicketSegmentedControl

class HomeViewController: UIViewController, HomeScreenDataDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var gradientContainer: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var leftStat: UILabel!
    @IBOutlet var middleStat: UILabel!
    @IBOutlet var rightStat: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var followersContainer: UIView!
    @IBOutlet var followedContainer: UIView!
    @IBOutlet var newsFeedContainer: UIView!
    var gradientLayer:CAGradientLayer!
    
    
    let titles:[String] = ["Friends Online", "Start A Party", "Join Random Party", "Connect Other Accounts", "Profile Settings"]
    let descriptions:[String] = ["3 Currently Active", "Create A Joinable Session", "Find A Session To Join", "Access More Music", "Edit User Profile"]
    let iconNames:[String] = ["icons8-Friends Filled-100", "icons8-User Groups Filled-100", "icons8-Joining Queue Filled-100","icons8-Password Filled-100", "icons8-ID Verified Filled-100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Create Blur On Top of Header
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = headerImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerImageView.addSubview(blurEffectView)
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width/2
        self.userImageView.layer.borderColor = UIColor.white.cgColor
        self.userImageView.layer.borderWidth = 0
        
        /*
        let titles = ["Updates", "Followers", "Following"]
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.isSliderShadowHidden = true
        segmentedControl.move(to: 0)
        */
        
        //createGradientLayer()
        
        usernameLabel.text = AccountManager.sharedInstance.currentUser?.email ?? "Email N/A"
        displayNameLabel.text = AccountManager.sharedInstance.currentUser?.displayName ?? "No Display Name Set"
        AccountManager.sharedInstance.homeDataDelegate = self
        
        followersContainer.isHidden = true
        followedContainer.isHidden = true
        newsFeedContainer.isHidden = false
        
        
        //Add Accent To the Top of the TableView
        /*
        let topAccent = CALayer()
        topAccent.frame = CGRect(x: 0, y: self.gradientContainer.frame.height-1, width: self.view.frame.width, height: 1)
        topAccent.backgroundColor = UIColor.white.cgColor
        self.gradientContainer.layer.addSublayer(topAccent)
        */
        
        
        
        newDataRecieved()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
    func didSelect(_ segmentIndex: Int) {
        print("Selected: \(segmentIndex)")
        
        switch segmentIndex {
        case 0:
            followersContainer.isHidden = true
            followedContainer.isHidden = true
            newsFeedContainer.isHidden = false
            break
        case 1:
            followedContainer.isHidden = true
            newsFeedContainer.isHidden = true
            followersContainer.isHidden = false
            break
        case 2:
            newsFeedContainer.isHidden = true
            followersContainer.isHidden = true
            followedContainer.isHidden = false
            break
        default:
            break
        }
    }
     */
    
    // TABLE VIEW FUNCTIONS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        
        cell.mainTitleLabel.text = titles[indexPath.row]
        cell.subtitleLabel.text = descriptions[indexPath.row]
        cell.iconImage.image = UIImage(named: iconNames[indexPath.row])
        //cell.contentView.layer.cornerRadius = 10
        cell.holderView.layer.cornerRadius = 10
        cell.holderView.layer.borderColor = UIColor.white.cgColor
        cell.holderView.layer.borderWidth = 1.0
        
        return cell
    }
    
    
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        //End Color For The Buttons
        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, endColor.cgColor ]
        gradientLayer.locations = [0.0, 0.24, 0.34]
        
        self.gradientContainer.layer.addSublayer(gradientLayer)
    }
    
    func newDataRecieved() {
        let manager = AccountManager.sharedInstance
        
        //Set Left Stat
        //Set Middle Stat
        leftStat.text = "\(manager.followers.count)"
        rightStat.text = "\(manager.playlists.count)"
        
        
        //To-Do: refreshTableViews()
        
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

protocol HomeScreenDataDelegate {
    func newDataRecieved()
}
