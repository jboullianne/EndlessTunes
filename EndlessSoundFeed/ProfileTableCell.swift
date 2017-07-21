//
//  ProfileTableCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileTableCell: UITableViewCell {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var activeNowContainer: UIStackView!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var idTag: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var leftStatLabel: UILabel!
    @IBOutlet var rightStatLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    
    var rowUser:SearchManager.ETUser?

    var gradientLayer:CAGradientLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        setupRow()
        loadUserData()
        
        
        
    }
    
    func setupRow() {
        //Create Gradient Layer
        self.gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.backgroundImageView.frame.width + 50, height: self.backgroundImageView.frame.height)
        
        let startColor = UIColor(red: 43/255, green: 46/255, blue: 77/255, alpha: 0.55).cgColor
        let endColor = UIColor(red: 29/255, green: 121/255, blue: 191/255, alpha: 0.55).cgColor
        gradientLayer.colors = [startColor, endColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        self.backgroundImageView.layer.addSublayer(gradientLayer)
        
        //Shape ID Tag
        self.idTag.layer.borderWidth = 1
        self.idTag.layer.borderColor = UIColor.white.cgColor
        self.idTag.layer.cornerRadius = self.idTag.frame.height/2
        
        //Shape User Icon
        self.userIcon.layer.borderWidth = 1
        self.userIcon.layer.borderColor = UIColor.white.cgColor
        self.userIcon.layer.cornerRadius = self.userIcon.frame.width/2
        
        self.followButton.layer.cornerRadius = 4
    }
    
    func loadUserData() {
        
        //Load another User's Profile Information
        if let user = rowUser {
            //Set Information On Row
            displayNameLabel.text = user.displayName
            idLabel.text = user.email 
            
            followButton.isHidden = false
            
            //Follower Data Set Statistics Labels
            //leftStatLabel.text = "\(manager.following.count)"
            //rightStatLabel.text = "\(manager.followers.count)"
            
        }else{ //Load The Current User's Profile Information
            let manager = AccountManager.sharedInstance
            
            //Set Information On Row
            displayNameLabel.text = manager.currentUser?.displayName ?? "No Display Name Set"
            idLabel.text = manager.currentUser?.email ?? "No Email Set"
            
            //Follower Data Set Statistics Labels
            leftStatLabel.text = "\(manager.following.count)"
            rightStatLabel.text = "\(manager.followers.count)"
            followButton.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
