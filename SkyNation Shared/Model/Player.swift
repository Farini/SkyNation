//
//  Player.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation


/// **Private** information about the `Player`
class SKNPlayer:Codable, Identifiable {
    
    // IDs
    var id:UUID
    var localID:UUID            // id given by local machine
    var serverID:UUID?          // an ID given by the server
    var guildID:UUID?           // id of the Guild
    var deliveryTokens:[UUID]   // Free deliveries
    var timeTokens:[UUID]       // Tokens to cut through time
    var purchases:[UUID]        // Purchases this player made
    
    // Constructed
    var name:String
    var logo:String?
    var money:Int
    var about:String
    var experience:Int
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
    
    init() {
        self.id = UUID()
        self.localID = UUID()
        self.serverID = nil
        self.guildID = nil
        self.deliveryTokens = [UUID(), UUID(), UUID()]
        self.timeTokens = [UUID(), UUID()]
        self.purchases = []
        
        self.name = "Test Player"
        self.logo = nil
        self.money = 1000000 // 1 million
        self.about = "Nothing about"
        self.experience = 0
        self.beganGame = Date()
        self.lastSeen = Date()
    }
    
}

class PlayerPreferences:Codable {
    // Lights?
    // Sounds?
    // Notifications?
    // Graphics?
    // Tutorials?
}

/// `Public` information about a `Player`
struct PlayerCard {
    
    var id:UUID
    
    // Constructed
    var name:String
    var logo:String?
    var money:Int
    var about:String
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
}
