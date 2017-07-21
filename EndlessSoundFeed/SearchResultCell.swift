//
//  SearchResultCell.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet var mediaView: UIImageView!
    @IBOutlet var mediaTitleLabel: UILabel!
    @IBOutlet var mediaDetailLabel: UILabel!
    @IBOutlet var sourceView: UIImageView!
    @IBOutlet var moreDetailImage: UIImageView!
    @IBOutlet var moreDetailView: UIView!
    
    var track:Track?
    var moreDetailsDelegate:TrackMoreDetailsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resultMorePressed(_ sender: Any){
        //print("Cell More Pressed", track?.title)
        moreDetailsDelegate?.showDetails(track: track!)
    }

}
