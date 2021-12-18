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
        
        // IDs
        let lid = UUID()
        self.id = lid
        self.localID = lid
        
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
        
        self.serverID = nil
        self.guildID = nil
    }
    
    func receiveFreebiesAndSave(currency:Int, newTokens:[UUID]) {
        self.money += currency
        guard newTokens.count <= 3 else { print("More than 3 tokens not allowed in a gift"); return }
//        self.timeTokens.append(contentsOf: newTokens)
        do {
            try LocalDatabase.shared.savePlayer(self)
            
        } catch {
            print("Could not save Player: \(error.localizedDescription)")
        }
        
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
    
    /// .Entry tokens that haven't been used.
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
                do {
                    try LocalDatabase.shared.savePlayer(self)
                    
                } catch {
                    print("Could not save Player: \(error.localizedDescription)")
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
            
            do {
                try LocalDatabase.shared.savePlayer(self)
                
            } catch {
                print("Could not save Player: \(error.localizedDescription)")
            }
            
//            let res = LocalDatabase.shared.savePlayer(player: self)
//            print("Save player: \(res)")
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

/** The Content used to **update**  a `DBPlayer` */
struct PlayerContent:Codable, Identifiable, Hashable {
    
    var id:UUID
    var localID:UUID            // id given by local machine
    var guildID:UUID?           // id of the Guild
    
    /// GameCenter ID
    var gcid:String?
    
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
        self.lastSeen = player.lastSeen
        self.gcid = player.gcid
    }
    
    /// Returns `LastSeen`
    func activity() -> String {
        let df = GameFormatters.dateFormatter
        return df.string(from: lastSeen)
    }
    
    func timeSinceOnline() -> Double {
        return Date().timeIntervalSince(lastSeen)
    }
    
    func makePlayerCard() -> PlayerCard {
        return PlayerCard(playerContent: self)
    }
    
    static func example() -> PlayerContent {
        let randomPlayer = SKNPlayer.randomPlayers(1).first!
        return PlayerContent(player: randomPlayer)
    }
}

// MARK: - New, Simpler Method

/// Used for Loging Player in
struct PlayerLogin: Codable {
    
    /// The `id` of `DBPlayer` object
    var pid:UUID
    
    /// The pass given by system (resettable)
    var pass:String
    
    /// Name of Player
    var name:String
    
    /// Ways in which a login can fail
    enum LogFail:Error {
        case noID
        case noPass
    }
    
    /// Tries to create a player. It can fail if player has no `playerID`, or `pass`
    static func create(player:SKNPlayer) throws -> PlayerLogin {
        
        guard let id = player.playerID else { throw LogFail.noID }
        guard let pass = player.keyPass else { throw LogFail.noPass }
        
        return PlayerLogin(pid: id, pass: pass, name: player.name)
    }
    
}

/// Used when creating a DBPlayer
struct PlayerCreate: Codable {
    
    // No ID
    
    /// id given by local machine
    var localID:UUID
    
    var name:String
    var avatar:String
    var money:Int
    var experience:Int
    
    // Dates
    var beganGame:Date
    
    /// Initialize when creating a DBPlayer
    init(player:SKNPlayer) {
        self.localID = player.localID
        self.name = player.name
        self.avatar = player.avatar
        self.experience = player.experience
        self.money = player.money
        self.beganGame = player.beganGame
    }
}

/// Used when Updating a Player
struct PlayerUpdate: Codable, Equatable {
    
    /// ID of `DBPlayer`
    var id:UUID
    
    /// id given by local machine
    var localID:UUID
    
    /// id of the Guild (Optional)
    var guildID:UUID?
    
    /// GameCenter ID
    var gcid:String?
    
    var name:String
    var avatar:String
    var money:Int
    var experience:Int
    
    // Dates
    var beganGame:Date
    var pass:String
    
    /// Tries to create a player. It can fail if player has no `playerID`, or `pass`
    static func create(player:SKNPlayer) throws -> PlayerUpdate {
        
        guard let id = player.playerID else { throw PlayerLogin.LogFail.noID }
        guard let pass = player.keyPass else { throw PlayerLogin.LogFail.noPass }
        
        return PlayerUpdate(player: player, id: id, pass: pass)
    }
    
    private init(player:SKNPlayer, id:UUID, pass:String) {
        
        self.id = id
        self.pass = pass
        
        self.localID = player.localID
        self.guildID = player.guildID
        self.name = player.name
        self.avatar = player.avatar
        self.money = player.money
        self.experience = player.experience
        self.beganGame = player.beganGame
        
        self.gcid = player.gcid
    }
}

/// Card representation of Player, to show to other Players
struct PlayerCard: Codable, Identifiable, Hashable {
    
    /// ID of `DBPlayer`
    var id:UUID
    
    /// id given by local machine
    var localID:UUID
    
    /// id of the Guild (Optional)
    var guildID:UUID?
    
    var name:String
    var avatar:String
    var experience:Int
    
    var lastSeen:Date
    
    init(playerContent:PlayerContent) {
        self.id = playerContent.id
        self.localID = playerContent.localID
        self.guildID = playerContent.guildID
        self.name = playerContent.name
        self.avatar = playerContent.avatar
        self.experience = playerContent.experience
        self.lastSeen = playerContent.lastSeen
    }
    
    // No initializers (Comes from Server)
//    static func generate() -> PlayerCard {
//        let card = PlayerCard(id: UUID(), localID: UUID(), guildID: UUID(), name: "Player One", avatar: "people_01", experience: 12, lastSeen: Date().addingTimeInterval(-500))
//        return card
//    }
}

// MARK: - Non-Codable

/// A Player and a Number. Useful for voting and displaying score (Contribution)
struct PlayerNumKeyPair {
    
    var player:PlayerCard
    var votes:Int
    
    init(_ player:PlayerContent, votes:Int) {
        self.player = PlayerCard(playerContent: player)
        self.votes = votes
    }
    
    init(_ card:PlayerCard, votes:Int) {
        self.player = card
        self.votes = votes
    }
    
    /// Helper function to generate this object with Player ID
    static func makeFrom(id:UUID, votes:Int) -> PlayerNumKeyPair? {
        guard let citizen = ServerManager.shared.serverData?.partners.first(where: { $0.id == id }) else {
            print("Could not find player with id: \(id)")
            return nil
        }
        return PlayerNumKeyPair(citizen, votes: votes)
    }
    
}
