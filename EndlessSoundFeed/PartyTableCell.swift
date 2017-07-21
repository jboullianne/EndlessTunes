//
//  PartyTableCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/16/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class PartyTableCell: UITableViewCell {

    @IBOutlet var npThumbView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var userCountLabel: UILabel!
    @IBOutlet var collabView: UIImageView!
    @IBOutlet var spView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
