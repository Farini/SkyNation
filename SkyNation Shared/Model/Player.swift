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
    var shopped:Shopped
    
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
        self.shopped = Shopped(lid: lid)
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
    
    // MARK: - Other Objects
    /*
    func getCard() -> PlayerCard {
        let card:PlayerCard = PlayerCard(id: self.id, name: self.name, avatar: self.avatar, money: self.money, about: "", beganGame: self.beganGame, lastSeen: self.lastSeen)
        return card
    }
    */
    
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










// MARK: - New Store Logic

/// The types of Token, to keep track of where they come from.
enum TokenType:String, Codable, CaseIterable {
    
    case Purchased
    case Freebie
    case Entry      // mars entry
    case Beginner   // Game Beginner's package
    case Promo      // Any promotion made
    
    /// Indicates whether player ID is also the one using. (or if it needs a playerID to check)
    var needsPlayerPass:Bool {
        switch self {
            case .Purchased, .Freebie, .Beginner: return true
            case .Entry, .Promo: return false
        }
    }
}

/// A Token generated by the game (or server)
struct GameToken:Codable {
    
    var id:UUID
    var date:Date
    var user:UUID
    var origin:TokenType
    
    var usedDate:Date?
    var usedBy:UUID?
    
    // Game Freebies
    init(free pid:UUID) {
        self.id = UUID()
        self.date = Date()
        self.user = pid
        self.origin = .Freebie
    }
    
    // Purchases
    init(purchase:Purchase, userID:UUID) {
        // Validate purchase
        self.id = UUID()
        self.date = Date()
        self.user = userID
        self.origin = .Purchased
    }
    
    // Entry (invite)
    init(entry pid:UUID) {
        self.id = UUID()
        self.date = Date()
        self.user = pid
        self.origin = .Entry
    }
    
    // Beginner package
    init(beginner pid:UUID) {
        self.id = UUID()
        self.date = Date()
        self.user = UUID()
        self.origin = .Beginner
        
    }
    
    func validate(pid:UUID) -> Bool {
        if usedDate != nil { return false }
        
        if origin.needsPlayerPass == true {
            return pid == user
        } else {
            return true
        }
    }
    
    static func createUsedCopy(token:inout GameToken) {
        token.usedDate = Date()
    }
}

/// The 3 types of Product
enum GameProductType:Int, Codable, CaseIterable {
    
    /// A Five dollar product
    case five = 5
    
    /// Ten dollar product
    case ten = 10
    
    /// Twenty dollar product
    case twenty = 20
    
    /// Amount of Tokens that comes with this Product
    var tokenAmount:Int {
        return 3 * self.rawValue
    }
    
    /// Amount of Kits that comes with this Product
    var kitAmount:Int {
        return 2 * self.rawValue
    }
    
    var moneyAmount:Int {
        return self.rawValue * 1500
    }
    
    var displayName:String {
        switch self {
            case .five: return "Push Package"
            case .ten: return "Big Package"
            case .twenty: return "Hude Deal"
        }
    }
    
    var fakePrice:Double {
        switch self {
            case .five: return 5.0
            case .ten: return 10.0
            case .twenty: return 20.0
        }
    }
}

/// Objects represents one Purchase made in the store
struct Purchase:Codable, Identifiable, Hashable {
    
    var id:UUID
    var receipt:String
    var date:Date
    var storeProduct:GameProductType
    
    /// Kits that can be purchased
    enum Kit:String, Codable, CaseIterable {
        
        case SurvivalKit
        case BotanistGarden
        case BuildersTech
        case Humanitarian
        
        var tanks:[TankType:Int] {
            switch self {
                case .SurvivalKit:
                    return [.o2:15, .h2o:20, .air:3]
                case .BotanistGarden:
                    return [.o2:5, .h2o:5, .air:3]
                case .BuildersTech:
                    return [.h2o:5, .air:3]
                case .Humanitarian:
                    return [:]
            }
        }
        
        var boxes:[Ingredient:Int] {
            switch self {
                case .SurvivalKit:
                    return [.Food:15]
                case .BotanistGarden:
                    return [.Fertilizer:8]
                case .BuildersTech:
                    return [.Aluminium:12, .Battery:2]
                case .Humanitarian:
                    return [.Food:10]
            }
        }
        
        var displayName:String {
            switch self {
                case .SurvivalKit:
                    return "Survival Kit"
                case .BotanistGarden:
                    return "Bio Garden"
                case .BuildersTech:
                    return "Techie Tech"
                case .Humanitarian:
                    return "Human Heart"
            }
        }
        
        
        //        var rawKit:[String:Int] {
        //            var baseKit:[String:Int] = [:]
        //
        //        }
        
        //    func getKitTanks() -> [String:Int] {
        //        return [:]
        //    }
        //
        //    func getKitBoxes() -> [String:Int] {
        //        return [:]
        //    }
        //
        //    func getKitBio() -> [String:Int] {
        //        return [:]
        //    }
    }
    
    var kits:[Purchase.Kit]
    
    var used:Bool = false
    
    init(product:GameProductType, kit:Purchase.Kit, receipt:String) {
        self.id = UUID()
        self.receipt = receipt
        self.date = Date()
        self.storeProduct = product
        self.used = false
        self.kits = [kit]
    }
    
    func getTokens() -> [GameToken] {
        var gTokens:[GameToken] = []
        
        let amt:Int = self.storeProduct.tokenAmount
        for i in 1...amt {
            print("Generating token #\(i)")
            // WARNING, ADD REAL USER ID
            let newToken = GameToken(purchase: self, userID: UUID())
            gTokens.append(newToken)
        }
        
        // 1 entry token
        // ADD REAL PLAYER ID
        let entryToken = GameToken(entry: UUID())
        gTokens.append(entryToken)
        
        return gTokens
    }
    
}

/// Where purchases get stored. (JSON) This object holds the purchases and tokens
class Shopped:Codable {
    
    static let beginTokens:Int = 10
    static let hireAmount:Int = 15
    
    var tokens:[GameToken]
    var purchases:[Purchase]
    
    var freebiesLast:Date
    var freebiesMade:[String:Int]
    
    var staff:[Person]
    var dateStaff:Date
    
    /// Initializes with beginner's package
    init(lid:UUID) {
        var tokens:[GameToken] = []
        for _ in 1...Shopped.beginTokens {
            tokens.append(GameToken(beginner: lid))
        }
        self.tokens = tokens
        self.purchases = []
        self.freebiesLast = Date().addingTimeInterval(-1.0 * TimeInterval.oneDay)
        self.freebiesMade = [:]
        
        self.staff = []
        self.dateStaff = Date().addingTimeInterval(-1 * TimeInterval.oneDay)
    }
    
    // MARK: - Tokens
    
    func getSpendableTokens() -> [GameToken] {
        return tokens.filter({ $0.origin != .Entry })
    }
    
    func useToken(token:GameToken) -> Bool {
        if let _ = tokens.first(where: { $0.id == token.id }) {
            tokens.removeAll(where: { $0.id == token.id })
            var newToken = token
            GameToken.createUsedCopy(token: &newToken)
            self.tokens.append(newToken)
            return true
        } else {
            return false
        }
    }
    
    func getAToken() -> GameToken? {
        return tokens.first(where: { $0.origin != .Entry && $0.usedDate == nil })
    }
    
    // MARK: - Purchases
    
    func makePurchase(cart:Purchase) {
        guard !purchases.contains(cart) else { return }
        self.purchases.append(cart)
        let purchasedTokens = cart.getTokens()
        self.tokens.append(contentsOf: purchasedTokens)
        
    }
    
    func unusedPurchases() -> [Purchase] {
        return purchases.filter({ $0.used == false })
    }
    
    // MARK: - Staff List
    
    /// Gets the generated people, Generates new list of over 1hr, and Generates new list is `useTokens` == true
    func getPeople(_ useTokens:Bool = false) -> [Person] {
        
        // Check if should renew the list
        var shouldGenerate:Bool = false
        if timeToGenerateNextPeople() > 0 {
            if useTokens == true || staff.isEmpty == true {
                shouldGenerate = true
            }
        } else {
            shouldGenerate = true
        }
        
        if shouldGenerate {
            print("Generating new people")
        } else {
            print("Reusing old staff")
        }
        
        if shouldGenerate {
            let newStaff = self.generatePeople(amt: Shopped.hireAmount)
            self.staff = newStaff
            return newStaff
        } else {
            return staff
        }
    }
    
    func timeToGenerateNextPeople() -> Double {
        
        let delay = Double(TimeInterval.oneDay / 24) // 1hr
        let duration = Date().timeIntervalSince(self.dateStaff)
        
        let isReady:Bool = duration > delay
        print("Duration: \(duration), Ready: \(isReady)")
        
        if duration > delay {
            // ready
            return 0
        } else {
            // not ready
            return delay - duration
        }
    }
    
    private func generatePeople(amt:Int) -> [Person] {
        guard amt > 0 else { return [] }
        var gen:[Person] = []
        for i in 1...amt {
            let newPerson = Person(random: true)
            print("Generating #\(i), \(newPerson.name)")
            gen.append(newPerson)
        }
        return gen
    }
    
    func didHire(person:Person) {
        staff.removeAll(where: { $0.id == person.id })
    }
    
    // MARK: - Freebies
    
    /// Generates Free Stuff. Empty if not ready.
    func generateFreebie() -> [String:Int] {
        
        guard timeToGenerateNextFreebie() < 1.0 else { return [:] }
        
        // Dictionary
        var dictionary:[String:Int] = [:]
        
        let array:[String] = [TankType.h2o.rawValue, TankType.o2.rawValue, TankType.air.rawValue, "token", "money"]
        let rnd1 = array.randomElement()!
        dictionary[rnd1, default:0] += 1
        
        // Update the date
        freebiesLast = Date()
        
        return dictionary
    }
    
    func timeToGenerateNextFreebie() -> Double {
        
        let delay = Double(TimeInterval.oneDay)
        let duration = Date().timeIntervalSince(self.freebiesLast)
        
        let isReady:Bool = duration > delay
        print("Duration: \(duration), Ready: \(isReady)")
        
        if duration > delay {
            // ready
            return 0
        } else {
            // not ready
            return delay - duration
        }
    }
    
}
