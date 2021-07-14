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
    var serverID:UUID?          // an ID given by the server (SKNUser)
    var playerID:UUID?          // an ID for the `DBPlayer` object
    var gcid:String?            // an ID given by GameCenter
    var guildID:UUID?           // id of the Guild
    var cityID:UUID?            // City ID
    var deliveryTokens:[UUID]   // Free deliveries
    var timeTokens:[UUID]       // Tokens to cut through time
    var purchases:[UUID]        // Purchases this player made
    
    // Constructed
    var name:String
    var avatar:String
    var money:Int
    var about:String
    var experience:Int
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
    
    // Server Pass
    var datePass:Date?
    var keyPass:String?
    
    init() {
        
        let tokenAmount = 15
        var givenTokens:[UUID] = []
        for _ in 1...tokenAmount {
            givenTokens.append(UUID())
        }
        
        self.id = UUID()
        self.localID = UUID()
        self.serverID = nil
        self.guildID = nil
        self.deliveryTokens = [UUID(), UUID(), UUID()]
        self.timeTokens = givenTokens
        self.purchases = []
        
        self.name = "Test Player"
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
    
    /// Random Data generation
    static func randomPlayers(_ amt:Int) -> [SKNPlayer] {
        
        var players:[SKNPlayer] = []
        let randomNames = ["Test", "Player One", "MarZ", "Moogle", "Rocketman", "Rocketgal", "Marizza", "⌘🤓.😬"]
        for _ in 1...amt {
            let newPlayer = SKNPlayer()
            newPlayer.name = randomNames.randomElement()!
            players.append(newPlayer)
        }
        return players
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

/**
 The Content used to **update**  a `DBPlayer`
 */
struct PlayerContent:Codable {
    
    var id:UUID
    var localID:UUID            // id given by local machine
    var guildID:UUID?           // id of the Guild
    
    var name:String
    var avatar:String
    var money:Int
    var about:String
    var experience:Int
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
    
    init(player:SKNPlayer) {
        self.id = player.id
        self.localID = player.localID
        self.guildID = player.guildID
        self.name = player.name
        self.avatar = player.avatar
        self.money = player.money
        self.about = player.about
        self.experience = player.experience
        self.beganGame = player.beganGame
        self.lastSeen = Date()
    }
    
    /// Returns `LastSeen`
    func activity() -> String {
        let df = GameFormatters.dateFormatter
        return df.string(from: lastSeen)
    }
    
    func timeSinceOnline() -> Double {
        return Date().timeIntervalSince(lastSeen)
    }
    
}

/**
 A base structure used to identify player, login, etc. */
struct SKNUserPost:Codable {

    var id:UUID         // Wildcard ID
    var name:String     // Name of Player
    var localID:UUID    // ID received when started game
    
    var serverID:UUID?  // The one created on here (server)
    
    /// Date last password is received
    var date:Date?
    
    /// A password defined by system
    var pass:String?
    
    /// The PlayerContent associated with the DBPlayer
    var player:PlayerContent?
    
//    var id: UUID
//    var name: String
//    var localID: UUID
//    var guildID: UUID?
//    var cityID: UUID?
//    var serverID: UUID?
//
//    /// Date last password is received
//    var date:Date?
//    /// A password defined by system
//    var pass:String?
//
//    /// The PlayerContent associated with the DBPlayer
//    var player:PlayerContent?

    init(name:String) {
        self.id = UUID()
        self.localID = UUID()
        self.name = name
    }

    init(player:SKNPlayer) {
        
        self.id = player.id
        self.name = player.name
        self.localID = player.localID
//        self.guildID = player.guildID
        self.serverID = player.serverID
        
        // Update Password only if 1 hour has not passed yet
        if let pDate = player.datePass,
           pDate.addingTimeInterval(60*60).compare(Date()) == .orderedAscending {
            self.date = player.datePass
            self.pass = player.keyPass
        }
        
        // player pptyd
        self.player = PlayerContent(player: player)
    }
}
