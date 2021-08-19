//
//  Ingredients.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SwiftUI

/// Enum of names of **Ingredient**
enum Ingredient:String, Codable, CaseIterable, Hashable {
    
    case Aluminium
    case CarbonFiber
    case Copper
    case Polimer    // Plastic
    case Lithium
    case Iron
    case Silica
    
    case SolarCell
    case Circuitboard
    case Sensor
    case DCMotor
    case Ceramic
    
    case Battery
    
    case Water
    case Food
    
    case wasteLiquid
    case wasteSolid
    
    case Fertilizer // Helps to grow plants
    
    // ⚠️ Write modifications here
    
    // + Cement
    case Cement
    // + Glass
    case Glass
    // + Alloy
    case Alloy
    
    /// Whether a Player can order this item
    var orderable:Bool {
        switch self {
//            case .wasteSolid, .wasteLiquid, .Silica: return false
            case .Silica: return false
            case .Cement, .Glass, .Alloy: return false
            case .CarbonFiber : return false // Deprecating
            default: return true
        }
    }
    
    /// The capacity of a box for that ingredient
    func boxCapacity() -> Int {
        switch self {
        case .Aluminium: return 20
        case .CarbonFiber: return 8
        case .Copper: return 12
        case .Polimer: return 30
        case .SolarCell: return 14
        case .Circuitboard: return 8
        case .DCMotor: return 8
        case .Battery: return 100
        case .Ceramic: return 6
        case .Food: return 75
        case .Silica: return 20
            
        case .wasteSolid: return 100
        case .wasteLiquid: return 100
            
        default:
            return 2
        }
    }
    
    /// The Price to order this ingredient
    var price:Int {
        switch self {
            case .wasteSolid, .wasteLiquid: return 50
            case .Aluminium, .Copper, .Polimer, .Lithium, .Water: return 100
            case .Battery, .DCMotor, .Fertilizer, .Iron: return 150
            case .CarbonFiber, .Ceramic, .Sensor, .Silica, .SolarCell: return 220
            case .Circuitboard: return 270
            default: return 100
        }
    }
    
    /// Swift UI's image
    func image() -> Image? {
        switch self {
            case .Aluminium: return Image("Aluminium")
            case .CarbonFiber: return nil
            case .Copper: return Image("Copper")
            case .Polimer: return Image("Polimer")
                
            case .SolarCell: return Image(systemName: "sun.dust") // sys
            case .Circuitboard: return Image(systemName: "memorychip") // sys
            case .Sensor: return Image(systemName: "badge.plus.radiowaves.forward") // sys
            case .Battery: return Image(systemName: "bolt.fill.batteryblock") // sys
            case .Water: return Image(systemName: "drop") // sys
            case .Ceramic: return Image(systemName:"squares.below.rectangle") // sys
            
            case .Food: return Image("Food")
            case .wasteSolid: return Image("WasteSolidBox") // poop
            case .DCMotor: return Image("DCMotor")
            
            case .Lithium: return Image("Lithium")
            case .Iron: return Image("Iron")
            case .wasteLiquid: return Image("WasteLiquidBox")
            case .Silica: return Image("Silica")
            case .Fertilizer: return Image("Fertilizer")
                
            case .Cement: return Image(systemName: "puzzlepiece")
            case .Glass: return Image(systemName: "plus.circle")
            case .Alloy: return Image(systemName: "triangle.circle")
        }
    }
}

/// A box container that holds solid `Ingredients`
class StorageBox:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:Ingredient
    var capacity:Int { return type.boxCapacity() }
    var current:Int = 0
    
    init(ingType:Ingredient, current:Int) {
        self.type = ingType
        self.current = current
    }
    
    /**
     Fills the Box with the input.
     - Parameters:
     - input: The amount to fill
     - Returns: The amount left over, if the box is full   */
    func fillUp(_ input:Int) -> Int {
        let maxIntake = capacity - current
        if input >= maxIntake {
            self.current = capacity
            return input - maxIntake
        }else {
            self.current += input
            return 0
        }
    }
    
    static func == (lhs: StorageBox, rhs: StorageBox) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Make a class hashable: https://www.hackingwithswift.com/example-code/language/how-to-conform-to-the-hashable-protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



