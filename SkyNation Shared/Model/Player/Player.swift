//
//  Player.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 12/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

/*
 Player Goals:
 ------------
 1. Local (full player)     SKNPlayer
 2. Server (login)          SKNUserPost
 3. ServerDB                PlayerContent -> rename to PlayerCard?
 4. Card (content)          [Deprecated] PlayerCard
 
 Outpost Collection - City Data?
 1. Have a table with outpost indexes and date collected?
 
 */

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
    
    // var deliveryTokens:[UUID]   // Free deliveries
    // var timeTokens:[UUID]       // Tokens to cut through time
    // var purchases:[UUID]        // Purchases this player made
    
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
    
    /// Items Purchased, Tokens and Freebies
    var wallet:Wallet
    
    init() {
        
        let tokenAmount = 15
        var givenTokens:[UUID] = []
        for _ in 1...tokenAmount {
            givenTokens.append(UUID())
        }
        
        self.id = UUID()
        
        let lid = UUID()
        self.localID = lid
        
        self.serverID = nil
        self.guildID = nil
//        self.deliveryTokens = [UUID(), UUID(), UUID()]
//        self.timeTokens = givenTokens
//        self.purchases = []
        
        self.name = "Test Player"
        self.money = 200_000 // 200,000
        self.about = "About me"
        self.experience = 0
        self.beganGame = Date()
        self.lastSeen = Date()
        
        // opt
        let allAvatars = HumanGenerator().female_avatar_names + HumanGenerator().male_avatar_names
        self.avatar = allAvatars.randomElement()!
        
        // Shop (Initial)
        self.wallet = Wallet(lid: lid)
    }
    
    func receiveFreebiesAndSave(currency:Int, newTokens:[UUID]) {
        self.money += currency
        guard newTokens.count <= 3 else { print("More than 3 tokens not allowed in a gift"); return }
//        self.timeTokens.append(contentsOf: newTokens)
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
    
    // MARK: - Tokens
    
    func countTokens() -> [GameToken] {
        return wallet.tokens.filter({ $0.origin != .Entry && $0.usedDate == nil })
    }
    
    /// Use this before `useToken` to make sure Player has enough tokens
    func requestToken() -> GameToken? {
        return wallet.tokens.first(where: { $0.origin != .Entry && $0.usedDate == nil })
    }
    
    /// Use this after `getAToken` to make sure we can charge
    func spendToken(token:GameToken, save:Bool) -> Bool {
        if let _ = wallet.tokens.first(where: { $0.id == token.id }) {
            wallet.tokens.removeAll(where: { $0.id == token.id })
            var newToken = token
            GameToken.createUsedCopy(token: &newToken)
            wallet.tokens.append(newToken)
            if save == true {
                let res = LocalDatabase.shared.savePlayer(player: self)
                print("Save player: \(res)")
                if res == false {
                    print("⚠️ COULD NOT SAVE PLAYER")
                }
            }
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Entry Tokens
    
    /**
     Returns Bool (whether they can enter)
     - Token: False: `GameToken` is the first found (if any) - use it in the next function to consume,
     - Token: True:, `GameToken` is the used one */
    func marsEntryPass() -> (result:Bool, token:GameToken?) {
        let entryTokens = wallet.tokens.filter({ $0.origin == .Entry })
        if let used = entryTokens.first(where: { $0.usedDate != nil }) {
            return (true, used)
        } else {
            // Never used a token to enter mars ?
            return (false, entryTokens.first)
        }
    }
    
    /// Request after `marsEntryPass` returned FALSE, and unused `GameToken`
    func requestEntryToken(token:GameToken) -> GameToken? {
        
        if let _ = wallet.tokens.first(where: { $0.id == token.id }) {
            wallet.tokens.removeAll(where: { $0.id == token.id })
            var newToken = token
            GameToken.createUsedCopy(token: &newToken)
            wallet.tokens.append(newToken)
            
            let res = LocalDatabase.shared.savePlayer(player: self)
            print("Save player: \(res)")
            return newToken
            
        } else {
            return nil
        }
    }
    
    // MARK: - Other Objects
    
    func getPlayerContent() -> PlayerContent {
        return PlayerContent(player: self)
    }
    
}

/** A base structure used to identify player, login, etc. */
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

/** The Content used to **update**  a `DBPlayer` */

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

struct PlayerPost:Codable {
    
    // IDs
//    var id:UUID
    var localID:UUID            // id given by local machine
    var serverID:UUID?          // an ID given by the server (SKNUser)
    var playerID:UUID?          // an ID for the `DBPlayer` object
    var gcid:String?            // an ID given by GameCenter
    var guildID:UUID?           // id of the Guild
    var cityID:UUID?            // City ID
    
    // Constructed
    var name:String
    var avatar:String
    var money:Int
    var experience:Int
    
    // Dates
    var beganGame:Date
    var lastSeen:Date
    
    // Server Pass
    var datePass:Date?
    var keyPass:String?
    
    init(player:SKNPlayer) {
        self.localID = player.localID
        self.serverID = player.serverID
        self.playerID = player.playerID
        self.gcid = player.gcid
        self.guildID = player.guildID
        self.cityID = player.cityID
        self.name = player.name
        self.avatar = player.avatar
        self.money = player.money
        self.experience = player.experience
        self.beganGame = player.beganGame
        self.lastSeen = player.lastSeen
        self.datePass = player.datePass
        self.keyPass = player.keyPass
    }
}


/// `Public` information about a `Player`
/*
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
*/
