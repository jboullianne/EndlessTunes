//
//  PartyManager.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/13/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PartyManager {
    
    static let sharedInstance = PartyManager()
    
    struct ETParty {
        var partyID:String
        var name:String
        var ownerID:String
        var ownername:String
        var isPublic:Bool
        var isSpotifyEnabled:Bool
        var isCollaborative:Bool
        var npThumbURL:String?
        var image:UIImage?
        var userCount:Int
    }
    
    var party:ETParty?
    
    var ref:FIRDatabaseReference
    var trendingPartiesHandle:UInt?
    var trendingParties:[ETParty] = []
    
    var tpDataDelegate:TPDataDelegate?
    
    private init(){
        ref = FIRDatabase.database().reference()
        
        trendingPartiesHandle = ref.child("/p_parties").queryOrdered(byChild: "u_count").queryLimited(toLast: 12).observe(.value, with: { (snap) in
            print("TRENDING PARTIES: \(snap.value)")
            
            self.trendingParties.removeAll()
            
            for party in snap.children {
                let temp = party as! FIRDataSnapshot
                if let details = temp.value as? NSDictionary{
                    let partyID = temp.key
                    let name = details["name"] as! String
                    let ownerID = details["owneruid"] as! String
                    let ownername = details["ownername"] as! String
                    let isPublic = true
                    let isSpotifyEnabled = details["sp_enabled"] as! Bool
                    let isCollaborative = details["collab"] as! Bool
                    let npThumbURL = details["np_thumb"] as? String
                    let userCount = details["u_count"] as! Int
                    
                    let pResult = ETParty(partyID: partyID, name: name, ownerID: ownerID, ownername: ownername, isPublic: isPublic, isSpotifyEnabled: isSpotifyEnabled, isCollaborative: isCollaborative, npThumbURL: npThumbURL, image: nil, userCount: userCount)
                    self.trendingParties.append(pResult)
                }
            }
            
            self.trendingParties.reverse()
            print("SORTED PARTIES: \(self.trendingParties)")
            
            if let delegate = self.tpDataDelegate {
                delegate.tpDataUpdated()
            }
        })
    }
    
    //Starts a new ETParty with requested settings -> Returns True if Successful
    func startParty(name:String, ownerID:String, isPublic:Bool, isSpotifyEnabled:Bool, isCollaborative:Bool) -> Bool {
        
        return false
    }
    
    //Joins a party with the given partyID -> Returns True if Successful
    func joinParty(with partyId:String) -> Bool {
        print("To-Do: joinParty")
        return false
    }
    
    //Joins a Random Party -> Returns True if Successful
    func joinRandomParty() -> Bool {
        print("To-Do: Join Random Party")
        return false
    }
    
    //Requests To Leave Party -> Returns True if Successful
    func leaveParty() -> Bool{
        
        return false
    }
    
    //Queues Track in Current Party -> Returns ChildId of Queued Track (Handle to Track)
    func queueTrackInParty() -> String {
        
        return "To-Do: queueTrackInParty"
    }
    
    
}

protocol TPDataDelegate {
    func tpDataUpdated()
}
