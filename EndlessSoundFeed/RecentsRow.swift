//
//  RecentsRow.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class RecentsRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var manager:ETDataManager!
    
    var rowUser:SearchManager.ETUser?
    var recents:[[String]] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        manager = ETDataManager.sharedInstance
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //Load User Info If Not Nil
        if rowUser != nil {
            return recents.count
        }
        
        //Else Load Current User's Info
        return manager.rpInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCollectionCell", for: indexPath) as! RecentCollectionCell
        
        let index = indexPath.row
        
        let recent:[String]?
        
        if rowUser != nil {
            recent = recents[index]
        }else {
            recent = manager.rpInfo[index]
        }
        
        
        if let recent = recent {
            cell.titleLabel.text = recent[0]
            cell.sourceLabel.text = recent[1]
            
            //Load External Thumbnail if it Exists
            if(recent[2] != "" && manager.rpImages[index] == nil){
                
                Alamofire.request(recent[2]).responseImage { response in
                    
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        
                        DispatchQueue.main.async {
                            if let updatedCell = collectionView.cellForItem(at: indexPath) as? RecentCollectionCell {
                                updatedCell.thumbnailView.contentMode = .scaleAspectFill
                                updatedCell.thumbnailView.image = image
                                collectionView.reloadItems(at: [indexPath])
                            }
                            self.manager.rpImages[index] = image
                        }
                        
                    }
                }
            } else {
                cell.thumbnailView.image = manager.rpImages[index]
            }
        }
        
        return cell
    }
    
}

extension RecentsRow: ETDataManagerRecentsDelagate {
    func newRecentsReceived() {
        self.collectionView.reloadData()
    }
}
