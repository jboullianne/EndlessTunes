//
//  ETEvent.swift
//  EndlessSoundFeed
//
//  Created by Jean-Marc Boullianne on 6/18/17.
//  Copyright © 2017 Jean-Marc Boullianne. All rights reserved.
//

import Foundation

class ETEvent {
    
    var type:ETEventType
    var author:String
    var authorUID:String
    var track:Track?
    var playlist:Playlist?
    var follower:String?
    var followerUID:String?
    var date:Date
    
    init(type: ETEventType, author:String, authorUID:String, date:Date) {
        self.type = type
        self.author = author
        self.authorUID = authorUID
        self.date = date
    }
    
    
    
}

extension ETEvent {
    var dateString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        
        return dateFormatter.string(from: self.date)
    }
    
    static func getDateFromString(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        
        return dateFormatter.date(from: dateString)!
    }
    
    func timeStringFromNow() -> String {
        let dateInterval = DateInterval(start: self.date, end: Date())
        
        let difference = dateInterval.duration
        let minutes = Int(difference.divided(by: 60))
        let hours = Int(difference.divided(by: 3600))
        let days = Int(difference.divided(by: 86400))

        if(days > 1){
            return "\(days) days ago"
        }else if (days == 1){
            return "Yesterday"
        }else if(hours == 1){
            return "1 hour ago"
        }else if(hours > 1){
            return "\(hours) hours ago"
        }else if(minutes > 1){
            return "\(minutes) minutes ago"
        }
        return "Just Now"
    }
}

enum ETEventType {
    case SharedPlaylist
    case CreatedPlaylist
    case Activity
    
    func toString() -> String{
        switch self {
        case .Activity:
            return "Activity"
        case .CreatedPlaylist:
            return "Created Playlist"
        case .SharedPlaylist:
            return "Shared Playlist"
        }
    }
}
