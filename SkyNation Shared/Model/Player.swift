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

struct SKNUser:Codable {
    
    var id: UUID
    var name: String
    var localID: UUID
    var guildID: UUID?
    
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

enum GuildTerrainType:String, Codable, CaseIterable {
    case Terrain1
    case Terrain2
    case Terrain3
}

struct Guild:Codable {
    
//    static let schema = "guilds"
    
//    @ID(key: .id)
    var id: UUID
    
//    @Field(key: "name")
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
//    @OptionalParent(key:"player_id")
    var president:SKNUser?
    
    /// The @Children property creates a one-to-many relation between two models. It does not store any values on the root model.
//    @Children(for: \.$guild)
    var members:[SKNUser]
    
    /// Election Date (To change President)
//    @Field(key: "election")
    var election:Date
    
//    @Enum(key: "terraintype")
    var terrain:GuildTerrainType
    
//    init() { }
//
//    init(id: UUID? = nil, name:String, player:SKNUser) {
//        self.id = id
//        self.name = name
//        self.members = [player]
//        self.president  = player
//        self.election = Date().addingTimeInterval(60 * 60 * 24 * 7) // 7 days
//        self.terrain = .Terrain1
//    }
}
