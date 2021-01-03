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
    case Silicate
    
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
    
    /// Orderable from Earth Order
    var orderable:Bool {
        switch self {
        case .wasteSolid, .wasteLiquid, .Silicate: return false
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
            
        case .wasteSolid: return 100
        case .wasteLiquid: return 100
            
        default:
            return 2
        }
    }
    
    /// The Price to order this ingredient
    var price:Int {
        switch self {
            case .wasteSolid, .wasteLiquid: return 5
            case .Aluminium, .Copper, .Polimer, .Lithium, .Water: return 10
            case .Battery, .DCMotor, .Fertilizer, .Iron: return 15
            case .CarbonFiber, .Ceramic, .Sensor, .Silicate, .SolarCell: return 22
            case .Circuitboard: return 27
            default: return 10
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
            
            case .Food: return nil // don't have yet
            case .wasteSolid: return nil // poop
            case .DCMotor: return Image("DCMotor")
            
            case .Lithium: return Image("Lithium")
            case .Iron: return nil
            case .wasteLiquid: return nil
            case .Silicate: return nil
            case .Fertilizer: return nil
        }
    }
}
