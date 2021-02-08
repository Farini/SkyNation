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
    var cityID: UUID?
    
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
    
    var id: UUID
    
//    @Field(key: "name")
    var name: String
    
    // https://docs.vapor.codes/4.0/fluent/relations/
//    @OptionalParent(key:"player_id")
    var president:[String:UUID?]?
    
    /// The @Children property creates a one-to-many relation between two models. It does not store any values on the root model.
//    @Children(for: \.$guild)
    var members:[String:UUID?]?
    var citizens:[UUID]
    var isOpen:Bool
    
    /// Election Date (To change President)
//    @Field(key: "election")
    var election:Date
    
//    @Enum(key: "terraintype")
    var terrain:GuildTerrainType
    
    // Cities
    var cities:[DBCity]?
    
    // Outposts
    var outposts:[DBOutpost]?
    
}

struct DBCity:Codable {
    
    var id:UUID
    
    var guild:[String:UUID?]?
    
    var name:String
    
    var accounting:Date
    
    var owner:[String:UUID?]?
    
    var posdex:Int
}

enum OutpostType:String, CaseIterable, Codable {
    case Water
    case Silica
    case Energy
    case Biosphere
}

struct DBOutpost:Codable {
    
    
    var id:UUID
    
 
    var model:String
    
    var guild:[String:UUID?]?
    
    var type:OutpostType
    
    var level:Int
    
    var accounting:Date
    
//    init() {}
//
//    init(id: UUID? = nil, modelName:String, guildID:UUID, oType:OutpostType, date:Date? = nil, newLevel:Int? = nil) {
//
//        print("Creating Outpost Model: \(modelName), in \(guild.name)")
//
//        self.id = id
//        self.type = oType
//        self.model = modelName
//
//        self.level = newLevel ?? 0
//
//        self.accounting = date ?? Date()
//
//    }
    
}
