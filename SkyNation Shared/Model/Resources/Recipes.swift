//
//  Recipes.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SwiftUI

/// **Recipe** names - recipes create a `Peripheral` or other objects
enum Recipe:String, Codable, CaseIterable, Hashable {
    
    case Module
    case Node
    
    // [Peripherals]
    case Condensator
    case ScrubberCO2
    case Electrolizer
    case Methanizer
    case Radiator
    case SolarPanel
    case Battery
    case StorageBox
    case tank
    case Roboarm
    case WaterFilter      // Transforms part of wasteLiquid back into water (or water vapor, to be easier)
    case BioSolidifier    // Transforms wasteSolid into fertilizer?
    
    /// Gets the ingredients for recipe
    func ingredients() -> [Ingredient:Int] {
        switch self {
            case .Module: return [.Aluminium:35]
            case .Node: return [.Aluminium:15]
            case .SolarPanel: return [.Polimer:1, .SolarCell:2]
            case .Condensator: return [.Aluminium:2, .Copper:1, .Polimer:1]
            case .ScrubberCO2: return [.Polimer:1, .Copper:1]
            case .Electrolizer: return [.Polimer:1, .Copper:1, .Lithium:1]
            case .Methanizer: return [.Polimer:2, .Ceramic:1, .Circuitboard:1]
            case .Radiator: return [.Aluminium:2, .Ceramic:1, .Lithium:3]
            case .Battery: return [.Lithium:5, .Copper:1]
            case .StorageBox: return [.Polimer:5, .Aluminium:1]
            case .tank: return [.Aluminium:8, .Iron:1, .Polimer:1]
            case .Roboarm: return [.Circuitboard:4, .DCMotor:2, .Aluminium:4, .Polimer:2]
            case .WaterFilter: return [.Ceramic:1, .Copper:2, .Lithium:1, .Iron:1]
            case .BioSolidifier: return [.Ceramic:2, .Copper:4, .Silicate:2, .Iron:2]
        }
    }
    
    /// A String that explains what this recipe does.
    var elaborate:String {
        switch self {
            case .Condensator: return "Condensates the water vapor in the air into liquid water."
            case .ScrubberCO2: return "Cleans carbon dioxide from the air."
            case .Electrolizer: return "Makes electrolisys of the water, converting into oxygen + hydrogen"
            case .Methanizer: return "Transforms hydrogen and carbon dioxide into methane."
            case .Radiator: return "Maintains temperature."
            case .SolarPanel: return "Generates power and charges the batteries."
            case .Battery: return "Stores energy"
            case .BioSolidifier: return "Transforms poop into fertilizer."
            default: return ""
        }
    }
    
    /// Skills required
    func skillSet() -> [Skills:Int] {
        switch self {
            case .Module: return [.Material:1]
            case .Node: return [:]
            case .SolarPanel: return [.Handy:1, .Electric:1]
            case .ScrubberCO2: return [.Material:1]
            case .Methanizer: return [.Mechanic:1, .Electric:1]
            case .Radiator: return [.Material:1]
            case .StorageBox: return [.Material:1]
            case .Roboarm: return [.Electric:1, .SystemOS:1, .Mechanic:1]
            case .WaterFilter: return [.Electric:1, .Mechanic:1, .Material:1]
            case .BioSolidifier: return [.Electric:1, .Mechanic:2, .Material:1]
            default: return [.Handy:1]
        }
    }
    
    /// Returns null if doesn't require
    func requiresTechTreePass() -> String? {
        switch self {
            case .ScrubberCO2: return self.rawValue
            case .Methanizer: return self.rawValue
            case .Roboarm: return self.rawValue
                
            default: return nil
        }
    }
    
    /// The time until the recipe is ready
    func getDuration() -> Int {
        switch self {
        case .ScrubberCO2: return 5
        case .Methanizer: return 8
        
        default: return 2
        }
    }
    
    func makeProduct(argument:Any) -> Codable? {
        switch self {
        case .tank:
            if let string = argument as? String, let ttype:TankType = TankType(rawValue: string) {
                let tank:Tank = Tank(type:ttype)
                return tank
            }
        default: return nil
        }
        return nil
    }
    
    var image:Image {
        switch self {
            case .Condensator: return PeripheralObject(peripheral: .Condensator).getImage()!
            case .ScrubberCO2: return PeripheralObject(peripheral: .ScrubberCO2).getImage()!
            case .Electrolizer: return PeripheralObject(peripheral: .Electrolizer).getImage() ?? Image(systemName: "questionmark")
            case .Methanizer: return PeripheralObject(peripheral: .Methanizer).getImage() ?? Image(systemName: "questionmark")
            case .Radiator: return PeripheralObject(peripheral: .Radiator).getImage() ?? Image(systemName: "questionmark")
            case .SolarPanel: return PeripheralObject(peripheral: .solarPanel).getImage() ?? Image(systemName: "questionmark")
            case .Battery: return PeripheralObject(peripheral: .battery).getImage() ?? Image(systemName: "questionmark")
//            case .BioSolidifier: return PeripheralObject(peripheral: .).getImage() ?? Image(systemName: "questionmark")
            default: return Image(systemName: "questionmark")
        }
    }
}
