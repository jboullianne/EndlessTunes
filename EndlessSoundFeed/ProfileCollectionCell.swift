//
//  ProfileCollectionCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class ProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var displayNameLabel: UILabel!
    

    var isSetup:Bool = false
    
    func setup() {
        if !isSetup {
            self.userIcon.layer.borderWidth = 1
            self.userIcon.layer.borderColor = UIColor.white.cgColor
            self.userIcon.layer.cornerRadius = self.userIcon.frame.width/2
            self.isSetup = true
        }
    }
    
    
}
