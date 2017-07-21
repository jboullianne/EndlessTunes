//
//  ETDataManager.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 7/18/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation

class ETDataManager {
    
    static let sharedInstance = ETDataManager()
    
    //Recently Played Key Constant
    let RECENTS_KEY = "RecentlyPlayed"
    let MAX_RECENTS_SIZE = 12
    
    var recentsDelegate:ETDataManagerRecentsDelagate?
    
    var rpInfo:[[String]]
    var rpImages:[UIImage?]

    private init() {
        rpInfo = []
        rpImages = [UIImage?](repeating: nil, count: self.MAX_RECENTS_SIZE)
        retrieveRecentlyPlayed()
        
    }
    
    
    //Load Recently Played Details From User Defaults
    func retrieveRecentlyPlayed() {
        if let temp = UserDefaults.standard.array(forKey: self.RECENTS_KEY) {
            if let recents = temp as? [[String]] {
                self.rpInfo = recents
            }
        }
    }
    
    
    //Add To Recently Played and Queue Synchronization to User Defaults
    func addToRecents(track: Track) {
        
        //Add Recent To Recents List
        rpInfo.insert([track.title, track.sourceString, track.thumbnailURL], at: 0)
        
        shiftRecents()

        UserDefaults.standard.setValue(rpInfo, forKey: self.RECENTS_KEY)
        recentsDelegate?.newRecentsReceived()
    }
    
    //Shift Images and Removes Excess Recents
    func shiftRecents() {
        
        self.rpImages.insert(nil, at: 0)
        
        //Clear Old Recents out if list is too long
        if rpInfo.count > self.MAX_RECENTS_SIZE {
            rpInfo.removeLast()
            rpImages.removeLast()
        }
    }
}

extension ETDataManager: ManagerDataPurger {
    func purgeData() {
        //Clear User Defaults For Manager
        UserDefaults.standard.set(nil, forKey: self.RECENTS_KEY)
        
        
        self.rpImages = [UIImage?](repeating: nil, count: self.MAX_RECENTS_SIZE)
        self.rpInfo = []
    }
}


protocol ETDataManagerRecentsDelagate {
    func newRecentsReceived()
}

protocol ManagerDataPurger {
    func purgeData()
}
