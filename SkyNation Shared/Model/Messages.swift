//
//  Messages.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/23/21.
//

import Foundation

enum GameAchievementType {
    case tech(item:TechItems)
    case recipe(item:Recipe)
    case vehicleBuilt(type:EngineType)
    case vehicleLanding(vehicle:SpaceVehicle)
    
    case newDNA(dna:PerfectDNAOption)
    case learning(skill:Skills)
    case deliveryXP
    case experience
    
    func preString() -> String {
        switch self {
            case .tech(let item): return "Researched Tech \(item.rawValue)"
            case .recipe(let recipe): return "Made a recipe \(recipe.rawValue)"
            case .vehicleBuilt(let type): return "Space vehicle Built: \(type.rawValue)"
            case .vehicleLanding(let vehicle): return "Landed vehicle \(vehicle.name)"
            case .newDNA(let dna): return "DNA discovered: \(dna)"
            case .learning(let skill): return "Someone learned \(skill)"
            case .deliveryXP: return "Delivery arrived"
            case .experience: return "Gained experience"
        }
    }
}

class GameMessageBoard {
    
    static let shared:GameMessageBoard = GameMessageBoard()
    
    var messages:[GameMessage]
    
    private init() {
        messages = LocalDatabase.shared.gameMessages
    }
    
    func newAchievement(type:GameAchievementType, qtty:Int?, message:String?) {
        
        self.messages = LocalDatabase.shared.gameMessages
        
        let theMessage = message ?? "Game Achievement! \(type.preString())."
        let newMessage = GameMessage(type: .Achievement, date: Date(), message: theMessage, ingredientRewards: [.Food:10])
        messages.append(newMessage)
        
        // Save
        LocalDatabase.shared.gameMessages = messages
        LocalDatabase.shared.saveMessages()
        
        // Increase Player XP
        if let player = LocalDatabase.shared.player {
            player.experience += 1
            let result = LocalDatabase.shared.savePlayer(player: player)
            print("Saved Player \(result)")
        }
    }
}

struct GameMessage:Codable {
    
    var id:UUID = UUID()
    var type:GameMessageType
    var date:Date
    var message:String
    var isRead:Bool = false
    var isCollected:Bool = false
    
    // Optionals
    var moneyRewards:Int?
    var tokenRewards:[UUID]?
    var ingredientRewards:[Ingredient:Int]?
}

enum GameMessageType:String, Codable, CaseIterable {
    
    case SystemWarning
    case SystemError
    
    case Achievement
    case Tutorial
    case ChatMessage
    case FreeDelivery
    
    case Other
}
