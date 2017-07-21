//
//  PartiesRow.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/15/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PartiesRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TPDataDelegate {
    
    var manager:PartyManager!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        manager = PartyManager.sharedInstance
        manager.tpDataDelegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.trendingParties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PartyCollectionCell", for: indexPath) as! PartyCollectionCell
        
        let party:PartyManager.ETParty = manager.trendingParties[indexPath.row]
        
        
        //Load External Thumbnail if it Exists
        if(party.npThumbURL != nil && party.image == nil){
            
            Alamofire.request(party.npThumbURL!).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    
                    DispatchQueue.main.async {
                        let updatedCell = collectionView.cellForItem(at: indexPath) as! PartyCollectionCell
                        updatedCell.npThumbView.contentMode = .scaleAspectFill
                        updatedCell.npThumbView.image = image
                        
                    }
                    self.manager.trendingParties[indexPath.row].image = image
                }
            }
        }
        
        if(party.image != nil){
            cell.npThumbView.contentMode = .scaleAspectFill
            cell.npThumbView.image = party.image!
        }
        
        cell.partyNameLabel.text = party.name
        cell.ownerNameLabel.text = party.ownername
        
        if party.isCollaborative {
            cell.collabView.isHidden = false
        }else{
            cell.collabView.isHidden = true
        }
        
        if party.isSpotifyEnabled {
            cell.spView.isHidden = false
        }else{
            cell.spView.isHidden = true
        }
        
        cell.userCountLabel.text = "\(party.userCount)"
        
        
        cell.setup()
        
        return cell
    }
    
    func tpDataUpdated() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.collectionView.alpha = 0.0
        }) { (success) in
            self.collectionView.reloadData()
            UIView.animate(withDuration: 0.3, animations: { 
                self.collectionView.alpha = 1.0
            }, completion: { (success) in
                print("Reloaded Collection View")
            })
        }
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
