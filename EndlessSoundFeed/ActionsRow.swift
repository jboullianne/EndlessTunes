//
//  ActionsRow.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit

class ActionsRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCollectionCell", for: indexPath) as! ActionCollectionCell
        
        //cell.setup()
        
        return cell
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     let itemsPerRow:CGFloat = 4
     let hardCodedPadding:CGFloat = 5
     let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
     let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
     return CGSize(width: itemWidth, height: itemHeight)
     }
     */
    
}
