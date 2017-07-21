//
//  MenuCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/11/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var holderView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        if selected {
            holderView.backgroundColor = UIColor.lightGray
        }
        // Configure the view for the selected state
    }

}
