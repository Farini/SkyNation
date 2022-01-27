//
//  ChatBubbleController.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI

/*
enum ChatBubbleTab:String, CaseIterable {
    case Achievement
    case Freebie
    
    case Chat
    case Guild
    case Tutorial
    
    case Search
    
    var emoji:String {
        switch self {
            case .Achievement: return "🏆"
            case .Freebie: return "🎁"
            case .Chat: return "💬"
            case .Guild: return "🔰" // ⚙️
            case .Tutorial: return "🎓"
            case .Search: return "🔎" // 🔎❓
        }
    }
}
*/

enum GuildElectionState {
    
    /// No election happening
    case noElection
    
    /// Election hasn't started. Will start on 'until'
    case waiting(until:Date)
    
    /// Election with an Object
    case voting(election:Election)
    
    /// A simple String that summarizes this object, for display.
    var displayString:String {
        switch self {
            case .noElection: return "No election"
            case .waiting(until: let until): return "Waiting until \(GameFormatters.dateFormatter.string(from: until))"
            case .voting(election: let election): return "Voting Election object ID: \(String(describing: election.id))"
        }
    }
}
