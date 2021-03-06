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
    var gcid:String?            // an ID given by GameCenter
    var guildID:UUID?           // id of the Guild
    var deliveryTokens:[UUID]   // Free deliveries
    var timeTokens:[UUID]       // Tokens to cut through time
    var purchases:[UUID]        // Purchases this player made
    
    // Constructed
    var name:String
//    var logo:String?
    var avatar:String
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
//        self.logo = nil
        self.money = 200000 // 200,000
        self.about = "About me"
        self.experience = 0
        self.beganGame = Date()
        self.lastSeen = Date()
        
        // opt
        let allAvatars = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        self.avatar = allAvatars.randomElement()!
    }
    
    func receiveFreebiesAndSave(currency:Int, newTokens:[UUID]) {
        self.money += currency
        guard newTokens.count <= 3 else { print("More than 3 tokens not allowed in a gift"); return }
        self.timeTokens.append(contentsOf: newTokens)
        let result = LocalDatabase.shared.savePlayer(player: self)
        print("Saving Player result: \(result)")
    }
    
}


/// `Public` information about a `Player`
struct PlayerCard {
    
    var id:UUID
    
    // Constructed
    var name:String
    var avatar:String?
    var money:Int
    var about:String
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
}

struct SKNUser:Codable {
    
    var id: UUID
    var name: String
    var localID: UUID
    var guildID: UUID?
    var cityID: UUID?
    
    // avatar:String    // Player's avatar image
    // gcid:String      // Game Center id
    
    init(name:String) {
        self.id = UUID()
        self.localID = UUID()
        self.name = name
    }
    
    init(player:SKNPlayer) {
        self.id = player.id
        self.name = player.name
        self.localID = player.localID
        self.guildID = player.guildID
    }
}

/// To authenticate a player
struct SKNPlayerAuth:Codable {
    
    // To authenticate a player
    
    var name: String
    var localID: UUID
    
    var serverID: UUID?
    var guildID: UUID?
    var cityID: UUID?
    var authID: UUID?   // the ID allowed to post
    
}
