//
//  Playlist.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation

class Playlist{
    
    var name:String
    var tracks:[Track]
    var owner:String
    var thumbnailURL:String
    var id:String
    
    init(name:String, tracks:[Track], owner:String, thumbnailURL:String = "", id: String){
        self.name = name
        self.tracks = tracks
        self.owner = owner
        self.thumbnailURL = thumbnailURL
        self.id = id
    }
}
