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
    
    case newDNA(dna:DNAOption)
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

/*
 Achievement Types
 - lab recipe (recipe, tech)
 - lab tech
 - person study
 - person workout
 - biobox dna found
 - biobox created
 - vehicle built
 - vehicle launched
 - vehicle arrived
 - mars tech
 - mars guild tech
 */

/*
 Reward Types
 - money
 - token
 - experience
 */

/*
 Mission List
 - cleanup
 - change air filters
 - private sector experiment
 - broadcast, webinar
 - move dna to food
 - perform distance maneuver
 - remote work
 - system update
 - blog, vlog
 - documentation
 - perform spacewalk
 */

class GameMessageBoard {
    
    static let shared:GameMessageBoard = GameMessageBoard()
    
    var messages:[GameMessage]
    
    private init() {
        messages = LocalDatabase.shared.gameMessages
    }
    
    func newAchievement(type:GameAchievementType, money:Int, message:String?) {

        let theMessage = message ?? "\(type.preString())."
        var newMessage = GameMessage(type: .Achievement, message: theMessage, rewards: nil)
        if money > 0 {
            newMessage.moneyRewards = money
        }
        self.messages.append(newMessage)

        // Save
        // LocalDatabase.shared.gameMessages = self.messages
        // Save
        do {
            try LocalDatabase.shared.saveMessages(messages: self.messages)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
        // LocalDatabase.shared.saveMessages()

        // Increase Player XP
        let player = LocalDatabase.shared.player
            player.experience += 1
//            player.money += money
        
        // Save
        do {
            try LocalDatabase.shared.savePlayer(player)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
    }
}

struct GameMessage:Codable {
    
    var id:UUID
    var type:GameMessageType
    var date:Date
    var message:String
    var isRead:Bool
    var isCollected:Bool
    
    // Optionals
    var moneyRewards:Int?
    var tokenRewards:[UUID]?
    var ingredientRewards:[Ingredient:Int]?
    
    init(type:GameMessageType, message:String, rewards:[Ingredient:Int]? = nil) {
        self.id = UUID()
        self.type = type
        self.date = Date()
        self.message = message
        self.isRead = false
        self.isCollected = false
        self.ingredientRewards = rewards
    }
    
    mutating func collectReward() {
        self.isCollected = true
    }
    
}





/// Deprecate after stop using **Chat Bubble**
enum GameMessageType:String, Codable, CaseIterable {
    
    case Achievement
    case Freebie
    
    case Chat
    case Guild
    case Tutorial
    
    case Other
    
    var emoji:String {
        switch self {
            case .Achievement: return "🏆"
            case .Freebie: return "🎁"
            case .Chat: return "💬"
            case .Guild: return "🔰" // ⚙️
            case .Tutorial: return "🎓"
            case .Other: return "❓"
        }
    }
}

// MARK: - Chat

/// Used to post a `ChatMessage`
struct ChatPost:Codable {
    
    var guildID:UUID
    var playerID:UUID
    var name:String
    var date:Date
    var message:String
}

struct ChatMessage:Codable, Identifiable, Hashable {
    
    var id: UUID
    var guild: [String:UUID?]
    
    var pid: UUID
    var name: String
    var message: String
    var date: Date
    
//    init(from decoder: Decoder) throws {
//        if let v = decoder.container(keyedBy: CodingKeys.guild) {
//            
//        }
//    }
    
}
