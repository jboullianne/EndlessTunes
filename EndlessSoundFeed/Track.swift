//
//  Track.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 5/2/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class Track{
    
    var title:String        = ""
    var author:String       = ""
    var thumbnailURL:String = ""
    var smallThumbnailURL:String?
    var uri:String          = ""
    var source:TrackSource
    
    var thumbnailImage:UIImage?
    var smallThumbnailImage:UIImage?
    
    
    init(title:String, author:String, thumbnailURL:String?, uri:String, source:TrackSource){
        self.title = title
        self.author = author
        if(thumbnailURL == nil){
            self.thumbnailURL = ""
        }else{
            self.thumbnailURL = thumbnailURL!
        }
        self.uri = uri
        self.source = source
    }
    
    
}

enum TrackSource {
    case SoundCloud
    case Spotify
}

extension Track {
    var sourceString:String {
        switch self.source {
        case .Spotify:
            return "Spotify"
        case .SoundCloud:
            return "SoundCloud"
        }
    }
}
