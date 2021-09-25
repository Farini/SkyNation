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
            case .Biosphere: return [.Food:25]

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
            case .Antenna: return "Communication."
            case .Launchpad: return "Receives Space Vehicles."
            case .Arena: return "Gives entertainment to people."
            case .ETEC: return "Entertainment center provides entertainment."
            //            default: return ""
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
    case full           // can upgrade. Set date and proceed to cooldown
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
