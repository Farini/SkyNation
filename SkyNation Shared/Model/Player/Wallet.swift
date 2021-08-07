//
//  Wallet.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/7/21.
//

import Foundation

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
        var tokens:[GameToken] = []
        for _ in 1...Wallet.beginTokens {
            tokens.append(GameToken(beginner: lid))
        }
        self.tokens = tokens
        self.purchases = []
        self.freebiesLast = Date().addingTimeInterval(-1.0 * TimeInterval.oneDay)
        self.freebiesMade = [:]
        
        self.staff = []
        self.dateStaff = Date().addingTimeInterval(-1 * TimeInterval.oneDay)
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
        
    }
    
    var kits:[Purchase.Kit]
    
    var used:Bool
    var addedTokens:Bool
    var addedKit:Bool
    
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
