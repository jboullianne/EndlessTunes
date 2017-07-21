//
//  PartyCollectionCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class PartyCollectionCell: UICollectionViewCell {
    
    var isSetup:Bool = false
    
    @IBOutlet var npThumbView: UIImageView!
    @IBOutlet var partyNameLabel: UILabel!
    @IBOutlet var ownerNameLabel: UILabel!
    @IBOutlet var userCountLabel: UILabel!
    @IBOutlet var collabView: UIImageView!
    @IBOutlet var spView: UIImageView!
    
    
    func setup() {
        if !isSetup {
            self.layer.cornerRadius = 10
            self.isSetup = true
        }
    }
}
