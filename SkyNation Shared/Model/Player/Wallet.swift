//
//  Wallet.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/7/21.
//

import Foundation
import SwiftUI

/// Where purchases get stored. (JSON) This object holds the purchases and tokens
class Wallet:Codable {
    
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
        
        print("Initializing beginners package")
        
        var tokens:[GameToken] = []
        for _ in 1...Wallet.beginTokens {
            tokens.append(GameToken(beginner: lid))
        }
        
        self.tokens = tokens
        self.purchases = []
        self.freebiesLast = Date()
        self.freebiesMade = [:]
        
        self.staff = []
        self.dateStaff = Date()
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
            let newStaff = self.generatePeople(amt: Wallet.hireAmount)
            self.staff = newStaff
            self.dateStaff = Date()
            return newStaff
        } else {
            return staff
        }
    }
    
    func timeToGenerateNextPeople() -> Double {
        
        let delay = Double(TimeInterval.oneDay) / 24.0 // 1hr
        let refresh:Date = self.dateStaff.addingTimeInterval(delay) //Date().timeIntervalSince(self.dateStaff)
        
        if refresh.compare(Date()) == .orderedAscending {
            // refresh
            return 0
        } else {
            let delta = Date().timeIntervalSince(self.dateStaff)
            print("Will generate next staff list in \(delta)")
            return delta
        }
        
    }
    
    private func generatePeople(amt:Int) -> [Person] {
        guard amt > 0 else { return [] }
        var gen:[Person] = []
        for i in 1...amt {
            let newPerson = Person(random: true)
            if Bool.random() == true && Bool.random() == true {
                let learnable:Skills = [.Material, .Datacomm, .Electric, .Mechanic].randomElement()!
                newPerson.learnNewSkill(type: learnable)
            }
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
        
        // Dictionary
        var dictionary:[String:Int] = [:]
        
        let array:[String] = [TankType.h2o.rawValue, TankType.o2.rawValue, TankType.air.rawValue, "token", "money", "money", "money", "token"]
        
        let rnd1 = array.randomElement()!
        dictionary[rnd1, default:0] += 1
        
        if Bool.random() == true {
            let rnd2 = array.randomElement()!
            dictionary[rnd2, default:0] += 1
            if Bool.random() == true {
                let rnd3 = array.randomElement()!
                dictionary[rnd3, default:0] += 1
            }
        }
        
        self.freebiesMade = dictionary
        
        return dictionary
    }
    
    /// Returns the time remaining to claim freebie. 0.0 if can claim now
    func timeToGenerateNextFreebie() -> Double {
        
        // Get the date last generated
        let lastGen:Date = self.freebiesLast
        
        // Get the date its supposed to generate freebie
        let deadline:Date = lastGen.addingTimeInterval(TimeInterval.oneDay / 3.0)

        let delta = deadline.timeIntervalSinceNow
        
        return max(-0.0, delta)
        
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
                    return [.o2:20, .h2o:20, .air:10]
                case .BotanistGarden:
                    return [.o2:5, .h2o:20, .air:5]
                case .BuildersTech:
                    return [.h2o:5, .air:3, .ch4:2]
                case .Humanitarian:
                    return [:]
            }
        }
        
        var boxes:[Ingredient:Int] {
            switch self {
                case .SurvivalKit:
                    return [.Food:15]
                case .BotanistGarden:
                    return [.Fertilizer:20, .Food:5]
                case .BuildersTech:
                    return [.Aluminium:12, .Battery:6, .Copper:6, .Iron:3]
                case .Humanitarian:
                    return [.Food:50]
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
        
    }
    
    var kits:[Purchase.Kit]
    
    var used:Bool
    var addedTokens:Bool
    var addedKit:Bool
    
    /// Initting from the store
    init(product:GameProductType, kit:Purchase.Kit, receipt:String) {
        self.id = UUID()
        self.receipt = receipt
        self.date = Date()
        self.storeProduct = product
        self.used = false
        self.kits = [kit]
        
        self.addedTokens = false
        self.addedKit = false
    }
    
    /// Generates the Tokens for this purchase
    func getTokens() -> [GameToken] {
        
        var gTokens:[GameToken] = []
        
        let amt:Int = self.storeProduct.tokenAmount
        for i in 1...amt {
            print("Generating token #\(i)")
            // WARNING, ADD REAL USER ID
            let newToken = GameToken(purchase: self, userID: UUID())
            gTokens.append(newToken)
        }
        
        var entryTokensAmount:Int = 1
        var entryTokens:[GameToken] = []
        let entryID = LocalDatabase.shared.player.serverID ?? UUID()
        
        switch storeProduct {
            case .five:
                break
            case .ten:
                entryTokensAmount = 2
            case .twenty:
                entryTokensAmount = 3
        }
        
        // Add the Entry Tokens
        while entryTokensAmount > 0 {
            let newToken = GameToken(entry: entryID)
            entryTokens.append(newToken)
            entryTokensAmount -= 1
        }
        
        return gTokens
    }
    
}

/// Copy from Server's `Purchase`
struct DBPurchase:Codable, Identifiable, Hashable {
    
    var id: UUID
    
    var userid: UUID
    
    var receipt: String?
    
    var status: String?
    
    var product: String
    
    var notes: String?
    
    var datePurchased: Date
}
