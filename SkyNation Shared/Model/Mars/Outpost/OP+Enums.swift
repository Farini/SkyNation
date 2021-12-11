//
//  OP+Enums.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/8/21.
//

import Foundation

/// A type of outpost which decclares what the outpost does.
enum OutpostType:String, CaseIterable, Codable {
    
    case HQ
    case Water          // Produces Water
    case Silica         // OK Produces Silica
    case Energy         // OK Produces Energy
    case Biosphere      // OK Produces Food
    case Titanium       // OK Produces Titanium
    case Observatory    //
    case Antenna        // OK Comm
    case Launchpad      // OK Launch / Receive Vehicles
    case Arena          // Super Center
    case ETEC           // Extraterrestrial Entertainement Center
    
    /// Base Production at level 1
    var productionBase: [Ingredient:Int] {
        switch self {
            case .HQ: return [:]
            
            // Mining -> Ingredient
            case .Water: return [.Water:20]
            case .Silica: return [.Silica:10]
            case .Titanium: return [.Iron:5]
            
            // Others -> Energy, or Food
            case .Energy: return [.Battery:20]
            case .Biosphere: return [.Food:9]

            case .Observatory: return [:]
            case .Antenna: return [:]
            case .Launchpad: return [:]
            case .Arena: return [:]
            case .ETEC: return [:]
        }
    }
    
    /// Returns a Key, Value pair for production
    func baseProduce() -> (name:String, quantity:Int)? {
        switch self {
            
            // Mining -> Ingredient
            case .Water: return (Ingredient.Water.rawValue, 18)
            case .Silica: return (Ingredient.Silica.rawValue, 10)
            case .Titanium: return (Ingredient.Iron.rawValue, 5)
                
            // Others -> Energy, or Food
            case .Energy: return ("Energy", 27)
            case .Biosphere: return (Ingredient.Food.rawValue, 25)
                
            default: return nil
        }
    }
    
    func productionForCollection(level:Int) -> [String:Int] {
        
        // Test results:
        /*
         * Water
         Water level 0 -> ["Water": 2] L.
         Water level 1 -> ["Water": 11] L.
         Water level 2 -> ["Water": 20] L.
         Water level 3 -> ["Water": 29] L.
         Water level 4 -> ["Water": 47] L.
         Water level 5 -> ["Water": 74] L.
         
         * Energy
         Power level 0 -> ["Energy": 5] kw.
         Power level 1 -> ["Energy": 24] kw.
         Power level 2 -> ["Energy": 43] kw.
         Power level 3 -> ["Energy": 62] kw.
         Power level 4 -> ["Energy": 100] kw.
         Power level 5 -> ["Energy": 157] kw.
         
         * Biosphere
         Bio level 0 -> ["Food": 0] Food.
         Bio level 1 -> ["Food": 5] Food.
         Bio level 2 -> ["Food": 10] Food.
         Bio level 3 -> ["Food": 15] Food.
         Bio level 4 -> ["Food": 25] Food.
         Bio level 5 -> ["Food": 40] Food.
         */
        switch self {
                
            // Mining -> Ingredient
            case .Water:
                // How much to get at level 0
                let lvlZero:Int = 2
                
                // How much it gets for each level
                let lvlDelta:Int = 9
                
                let fiboRes:Int = level == 0 ? 0:GameLogic.fibonnaci(index: level) * lvlDelta
                let totalOutput = lvlZero + fiboRes
                
                return [Ingredient.Water.rawValue:totalOutput]
                
            case .Silica:
                
                // How much to get at level 0
                let lvlZero:Int = 0
                
                // How much it gets for each level
                let lvlDelta:Int = 4
                
                let fiboRes:Int = level == 0 ? 0:GameLogic.fibonnaci(index: level) * lvlDelta
                let totalOutput = lvlZero + fiboRes
                
                return [Ingredient.Silica.rawValue:totalOutput]
                
            case .Titanium:
                
                // How much to get at level 0
                let lvlZero:Int = 0
                
                // How much it gets for each level
                let lvlDelta:Int = 3
                
                let fiboRes:Int = level == 0 ? 0:GameLogic.fibonnaci(index: level) * lvlDelta
                let totalOutput = lvlZero + fiboRes
                
                return [Ingredient.Iron.rawValue:totalOutput]
                
                // return (Ingredient.Iron.rawValue, 5)
                
                // Others -> Energy, or Food
            case .Energy:
                
                // How much to get at level 0
                let lvlZero:Int = 5
                
                // How much it gets for each level
                let lvlDelta:Int = 19
                
                let fiboRes:Int = level == 0 ? 0:GameLogic.fibonnaci(index: level) * lvlDelta
                let totalOutput = lvlZero + fiboRes
                
                return ["Energy":totalOutput]
                
            case .Biosphere:
                
                // How much to get at level 0
                let lvlZero:Int = 0
                
                // How much it gets for each level
                let lvlDelta:Int = 4
                
                let fiboRes:Int = level == 0 ? 0:GameLogic.fibonnaci(index: level) * lvlDelta
                let totalOutput = lvlZero + fiboRes
                
                return [Ingredient.Food.rawValue:totalOutput]
                
            default: return [:]
        }
    }
    
    /// Happiness Production
    var happyDelta:Int {
        switch self {
            case .HQ: return 0
            case .Energy: return 0
            case .Water: return 0
            case .Silica: return -1
            case .Biosphere: return 3
            case .Titanium: return -1
            case .Observatory: return 2
            case .Antenna: return 1
            case .Launchpad: return 0
            case .Arena: return 5
            case .ETEC: return 3
        }
    }
    
    /// Energy production (Consumed as negative)
    var energyDelta:Int {
        switch self {
            case .HQ: return 0
            case .Energy: return 100
            case .Water: return -20
            case .Silica: return -25
            case .Biosphere: return -15
            case .Titanium: return -25
            case .Observatory: return -5
            case .Antenna: return -5
            case .Launchpad: return -10
            case .Arena: return -50
            case .ETEC: return -20
        }
    }
    
    /// A String representing this outpost, for display in the UI
    var displayName:String {
        switch self {
            case .HQ: return "Headquarters"
            case .Water: return "Water Well"
            case .Silica: return "Silica Mine"
            case .Energy: return "Power Plant"
            case .Biosphere: return "Biosphere"
            case .Titanium: return "Titanium Mine"
            case .Observatory: return "Observatory"
            case .Antenna: return "Antenna"
            case .Launchpad: return "Launch Pad"
            case .Arena: return "Arena - A Sports & Entertainment Center on Mars."
            default: return "Unknown Outpost"
        }
    }
    
    /// Explains what the outpost does
    var explanation:String {
        switch self {
            case .HQ: return "The Headquarters of this Guild."
            case .Water: return "Extracts ice from the soil."
            case .Silica: return "Extracts silica from the soil."
            case .Energy: return "Produces energy."
            case .Biosphere: return "Responsible for producing food from plants and animals."
            case .Titanium: return "Extracts Titanium from the soil."
            case .Observatory: return "Enables scientific experiments."
            case .Antenna: return "Enables Communication, in and outer space."
            case .Launchpad: return "Receives Space Vehicles."
            case .Arena: return "Gives entertainment to people."
            case .ETEC: return "Entertainment center provides entertainment."
//            default: return "Unknown Outpost"
        }
    }
    
    /// The position index (Posdex) that this outpost type can be
    var validPosDexes:[Posdex] {
        switch self {
            case .HQ: return [Posdex.hq]
            case .Water: return [Posdex.mining1]
            case .Silica: return [Posdex.mining2]
            case .Energy: return [Posdex.power1, Posdex.power2, Posdex.power3, Posdex.power4]
            case .Biosphere: return [Posdex.biosphere1, Posdex.biosphere2]
            case .Titanium: return [Posdex.mining3]
            case .Observatory: return [Posdex.observatory]
            case .Antenna: return [Posdex.antenna]
            case .Launchpad: return [Posdex.launchPad]
            case .Arena: return [Posdex.arena]
            case .ETEC: return [Posdex.arena]
        }
    }
}

/// Update state of an `Outpost`
enum OutpostState:String, CaseIterable, Codable {
    
    case collecting     // accepting contributions
    case cooldown       // wait for the date
    case finished       // ready for level upgrade
    case maxed          // no more upgrades
}

/// Result that comes from a function that checks if outpost can be upgraded.
enum OutpostUpgradeResult {
    case needsDateUpgrade
    case dateUpgradeShouldBeNil
    
    case noChanges
    case nextState(_ state:OutpostState)
    case applyForLevelUp(currentLevel:Int)
}
