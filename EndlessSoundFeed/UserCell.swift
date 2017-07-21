//
//  UserCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 6/19/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
